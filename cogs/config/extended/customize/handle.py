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
        resp = await self.bot.session.get(url)

        avatar = (
            f"data:image/png;base64,{base64.b64encode(resp).decode()}"
        )

        await self.bot.http.edit_my_member(
            ctx.guild.id,
            avatar=avatar
        )
        return await ctx.send(
            embed=Embed(
                description=f"{EMOJIS.CONTEXT.APPROVE} {ctx.author.mention}: **Profile picture** updated successfully!",
                color=COLORS.NEUTRAL,
            ).set_image(url=url)
        )

    async def edit_banner(self, ctx: Context, url: str):
        """Edit the bot's server banner."""
        resp = await self.bot.session.get(url)

        banner = (
            f"data:image/png;base64,{base64.b64encode(resp).decode()}"
        )

        await self.bot.http.edit_my_member(
            ctx.guild.id,
            banner=banner
        )
        return await ctx.send(
            embed=Embed(
                description=f"{EMOJIS.CONTEXT.APPROVE} {ctx.author.mention}: Banner updated successfully!",
                color=COLORS.NEUTRAL,
            ).set_image(url=url)
        )
    
    async def edit_bio(self, ctx: Context, bio: str):
        """Edit the bot's server bio.""" 
        await self.bot.http.edit_my_member(
            ctx.guild.id,
            bio=bio
        )
        return await ctx.approve("Bio updated successfully.")

    async def reset(self, ctx: Context):
        await self.bot.http.edit_my_member(ctx.guild.id, avatar=None)
        await self.bot.http.edit_my_member(ctx.guild.id, banner=None)
        await self.bot.http.edit_my_member(ctx.guild.id, bio=None)
        await ctx.guild.me.edit(nick=None)
        await ctx.approve("All customizations have been reset.")