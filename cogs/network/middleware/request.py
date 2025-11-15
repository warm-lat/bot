import time
import uuid
import asyncio
import traceback
import logging

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

log = logging.getLogger(__name__)


def register_request_middleware(app: FastAPI) -> None:
    """
    Register the request middleware on the provided FastAPI app.
    Call this once during app setup (after creating the `app`).
    Expects `app.state.bot` to be set (optional - middleware will still run
    but will skip redis logging if bot/redis is not present).
    """

    @app.middleware("http")
    async def request_middleware(request: Request, call_next):
        start_time = time.time()
        request_id = str(uuid.uuid4())[:8]
        path = request.url.path
        remote = None
        try:
            remote = request.client.host if request.client else "unknown"
        except Exception:
            remote = "unknown"

        try:
            response = await call_next(request)

            status = getattr(response, "status_code", None) or 0

            bot = getattr(request.app.state, "bot", None)
            try:
                # 429 handling and simple weblog throttling using redis if available
                if status == 429 and bot and getattr(bot, "redis", None):
                    ratelimit_key = f"ratelimit_log:{remote}:{path}"
                    if not await bot.redis.exists(ratelimit_key):
                        log.info(f"[{request_id}] Rate limited {request.method} {path} from {remote}")
                        await bot.redis.set(ratelimit_key, "1", ex=60)
                else:
                    log_key = f"weblogs:{path}:{remote}"
                    if bot and getattr(bot, "redis", None):
                        should_log = not await bot.redis.exists(log_key)
                        if should_log:
                            log.info(f"[{request_id}] {request.method} {path} from {remote}")
                            await bot.redis.set(log_key, "1", ex=60)
                    else:
                        # fallback logging when redis or bot not available
                        log.info(f"[{request_id}] {request.method} {path} from {remote} -> {status}")
            except Exception as e:
                # non-fatal logging/redis error
                log.warning(f"[{request_id}] logging/redis error: {e}")

            return response

        except asyncio.TimeoutError:
            duration = time.time() - start_time
            log.error(
                f"[{request_id}] Request timed out after {duration:.2f}s: {request.method} {path}"
            )
            return JSONResponse({"error": "Request timed out"}, status_code=504)

        except Exception as e:
            duration = time.time() - start_time
            log.error(
                f"[{request_id}] Error handling request after {duration:.2f}s: {request.method} {path}"
            )
            log.error(f"[{request_id}] Error details: {e}")
            log.error(f"[{request_id}] Traceback: {traceback.format_exc()}")
            return JSONResponse({"error": "Internal server error"}, status_code=500)