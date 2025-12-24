import base64
from typing import List
from yarl import URL
from discord import Embed

from core.client.context import Context
from main import Evict
from config import EMOJIS, COLORS

class EditMe:
    def __init__(self, bot: Evict):
        self.bot = bot

    async def edit_pfp(self, ctx: Context, url: str):
        """Edit the bot's server profile picture."""
        async with self.bot.session.get(url) as resp:
            data = await resp.read()

        avatar = f"data:image/png;base64,{base64.b64encode(data).decode()}"

        await self.bot.http.edit_my_member(
            ctx.guild.id,
            avatar=avatar
        )
        return await ctx.approve("Profile picture updated successfully.")

    async def edit_banner(self, ctx: Context, url: str):
        """Edit the bot's server banner."""
        async with self.bot.session.get(url) as resp:
            data = await resp.read()

        banner = f"data:image/png;base64,{base64.b64encode(data).decode()}"

        await self.bot.http.edit_my_member(
            ctx.guild.id,
            banner=banner
        )
        return await ctx.approve("Banner updated successfully.")
    
    async def edit_bio(self, ctx: Context, bio: str):
        """Edit the bot's server bio."""
        BIO_CHAR_LIMIT = 190

        sanitized_bio = " ".join(bio.split())

        if len(sanitized_bio) > BIO_CHAR_LIMIT:
            return await ctx.send(
                embed=Embed(
                    description=f"{EMOJIS.CONTEXT.ERROR} {ctx.author.mention}: Bio exceeds the {BIO_CHAR_LIMIT} character limit.",
                    color=COLORS.ERROR,
                )
            )

        await self.bot.http.edit_my_member(
            ctx.guild.id,
            bio=sanitized_bio
        )
        return await ctx.approve("Bio updated successfully.")

    async def reset(self, ctx: Context):
        await self.bot.http.edit_my_member(ctx.guild.id, avatar=None)
        await self.bot.http.edit_my_member(ctx.guild.id, banner=None)
        await self.bot.http.edit_my_member(ctx.guild.id, bio=None)
        await ctx.guild.me.edit(nick=None)
        await ctx.approve("All customizations have been reset.")