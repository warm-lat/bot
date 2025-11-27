import discord

from discord.ext.commands import hybrid, hybrid_group, has_permissions

from core.client.context import Context
from tools import CompositeMetaClass, MixinMeta
from .handle import EditMe

class Customize(MixinMeta, metaclass=CompositeMetaClass):
    """
    Cog for customizing bot appearance.
    """
    
    @hybrid_group(name="customize", aliases=["customization", "customise", "custom"], invoke_without_command=True)
    @has_permissions(manage_guild=True)
    async def customize(self, ctx: Context):
        return await ctx.send_help(ctx.command)
    
    @customize.command(name="bio", example="warm.lat")
    @has_permissions(manage_guild=True)
    async def customize_bio(self,ctx: Context, bio: str):
        await EditMe(self.bot).edit_bio(ctx, bio)
        
    @customize.command(name="pfp", aliases=["avatar"])
    @has_permissions(manage_guild=True)
    async def customize_pfp(self, ctx: Context, url: str=None):
        if url is None:
            if ctx.message.attachments:
                attachment = ctx.message.attachments[0]
                fp = await attachment.to_file()
            elif ctx.message.reference:
                ref_msg: Message = await ctx.channel.fetch_message(ctx.message.reference.message_id)
                if ref_msg.attachments:
                    attachment = ref_msg.attachments[0]
                    fp = await attachment.to_file()
                else:
                    return await ctx.warn("Please provide a URL or attachment for the profile picture.")
            else:
                return await ctx.warn("Please provide a URL or attachment for the profile picture.")
        await EditMe(self.bot).edit_pfp(ctx, fp)
        
    @customize.command(name="banner")
    @has_permissions(manage_guild=True)
    async def customize_banner(self, ctx: Context, url: str):
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
        
    @customize.command(name="reset")
    @has_permissions(manage_guild=True)
    async def customize_reset(self, ctx: Context):
        await EditMe(self.bot).reset(ctx)