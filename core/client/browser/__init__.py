from contextlib import asynccontextmanager
from http.cookiejar import MozillaCookieJar
from logging import getLogger
from secrets import token_urlsafe
from typing import AsyncGenerator, Literal, Optional
import sys, asyncio
from anyio import CapacityLimiter
from playwright.async_api import (
    Browser,
    BrowserContext,
    Page,
    Playwright,
    async_playwright,
)
from pydantic import BaseConfig, BaseModel

import config

# Ensure Windows event loop policy is set before any async operations
if sys.platform == "win32":
    try:
        asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())
    except Exception as e:
        print(f"Warning: Could not set Windows event loop policy: {e}")
    
log = getLogger("warm/browser")
jar = MozillaCookieJar()
jar.load("cookies.txt")


class CookieModel(BaseModel):
    name: str
    value: str
    url: Optional[str] = None
    domain: Optional[str] = None
    path: Optional[str] = None
    expires: int = -1
    httpOnly: Optional[bool] = False
    secure: Optional[bool] = False
    sameSite: Optional[Literal["Lax", "None", "Strict"]] = "Strict"

    class Config(BaseConfig):
        orm_mode = True
        from_attributes = True


class BrowserHandler:
    limiter: CapacityLimiter
    playwright: Optional[Playwright] = None
    browser: Optional[Browser] = None
    context: Optional[BrowserContext] = None

    def __init__(self) -> None:
        self.limiter = CapacityLimiter(4)

    async def cleanup(self) -> None:
        if self.playwright:
            await self.playwright.stop()

        if self.browser:
            await self.browser.close()

    async def init(self) -> None:
        try:
            await self.cleanup()
            
            try:
                self.playwright = await async_playwright().start()
                log.info("Playwright started successfully")
            except NotImplementedError as e:
                if sys.platform == "win32":
                    asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())
                    log.info("Reset Windows event loop policy, restarting...")
                    self.playwright = await async_playwright().start()
                else:
                    raise
            except Exception as e:
                log.error(f"Failed to start Playwright: {e}")
                raise
            
            self.browser = await self.playwright.chromium.launch(
                headless=True,
                args=[
                    '--no-sandbox',
                    '--disable-dev-shm-usage',
                    '--disable-web-security',
                    '--disable-blink-features=AutomationControlled'
                ]
            )
            log.info("Browser launched successfully")
            
            self.context = await self.browser.new_context(
                user_agent=(
                    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
                    "(KHTML, like Gecko) Chrome/140.0.7339.16 Safari/537.36"
                ),
            )
            log.info("Browser context created successfully")
            
            try:
                await self.context.add_cookies(
                    [
                        cookie.dict(exclude_unset=True)
                        for _cookie in jar
                        if (cookie := CookieModel.from_orm(_cookie))
                    ]  # type: ignore
                )
                log.info("Cookies loaded successfully")
            except Exception as e:
                log.warning(f"Failed to load cookies: {e}")
                
        except Exception as e:
            log.error(f"Failed to initialize browser: {e}")
            # Don't re-raise the exception to allow the bot to continue without browser functionality
            log.warning("Browser functionality will be disabled")
            self.playwright = None
            self.browser = None
            self.context = None

    @asynccontextmanager
    async def borrow_page(self) -> AsyncGenerator[Page, None]:
        if not self.context:
            raise RuntimeError("Browser context is not initialized or browser functionality is disabled.")

        await self.limiter.acquire()
        identifier, page = token_urlsafe(12), await self.context.new_page()
        log.debug("Borrowing page ID %s.", identifier)
        try:
            yield page
        finally:
            self.limiter.release()
            await page.close()
            log.debug("Released page ID %s.", identifier)
            
    def is_available(self) -> bool:
        """Check if browser functionality is available."""
        return self.playwright is not None and self.browser is not None and self.context is not None
