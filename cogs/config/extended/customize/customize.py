import discord

from discord import Message
from discord.ext.commands import group, has_permissions

from core.client.context import Context
from tools import CompositeMetaClass, MixinMeta
from .handle import EditMe

class Customize(MixinMeta, metaclass=CompositeMetaClass):
    """
    Cog for customizing bot appearance.
    """
    
    @group(name="customize", aliases=["customization", "customise", "custom"], invoke_without_command=True)
    @has_permissions(manage_guild=True)
    async def customize(self, ctx: Context):
        """Group command for customizing bot appearance."""
        return await ctx.send_help(ctx.command)
    
    @customize.command(name="bio", example="warm.lat")
    @has_permissions(manage_guild=True)
    async def customize_bio(self,ctx: Context, *, bio: str):
        """Customize the bot's bio."""
        await EditMe(self.bot).edit_bio(ctx, bio)
        
    @customize.command(name="pfp", aliases=["avatar"])
    @has_permissions(manage_guild=True)
    async def customize_pfp(self, ctx: Context, *, url: str):
        """Customize the bot's profile picture."""
        if url is None:
            if ctx.message.attachments:
                url = ctx.message.attachments[0].url
            elif ctx.message.reference:
                ref_msg: Message = await ctx.channel.fetch_message(ctx.message.reference.message_id)
                if ref_msg.attachments:
                    url = ref_msg.attachments[0].url
            else:
                return await ctx.warn("Please provide a URL or attachment for the profile picture.")
        await EditMe(self.bot).edit_pfp(ctx, url)
        
    @customize.command(name="banner")
    @has_permissions(manage_guild=True)
    async def customize_banner(self, ctx: Context, *, url: str):
        """Customize the bot's profile banner."""
        if url is None:
            if ctx.message.attachments:
                url = ctx.message.attachments[0].url
            elif ctx.message.reference:
                ref_msg: Message = await ctx.channel.fetch_message(ctx.message.reference.message_id)
                if ref_msg.attachments:
                    url = ref_msg.attachments[0].url
            else:
                return await ctx.warn("Please provide a URL or attachment for the profile banner.")
        await EditMe(self.bot).edit_banner(ctx, url)
        
    @customize.command(name="reset", aliases=["default", "restore"])
    @has_permissions(manage_guild=True)
    async def customize_reset(self, ctx: Context):
        """Reset the bot's appearance to default."""
        await EditMe(self.bot).reset(ctx)