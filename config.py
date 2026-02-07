from sre_parse import SPECIAL_CHARS
from qtpy import API


class COLORS:
    """
    Changes the colors on context outputs.
    """
    NEUTRAL = 0xfdff99
    APPROVE = 0x20d927
    WARN = 0xf1d332
    DENY = 0xd1361e
    SPOTIFY = 0x1DB954

class EMOJIS:
    
    class DOCKET:
        INFO: str = ""
        YELLOW: str = ""
        BLACK: str = ""
        PURPLE: str = ""
        GREEN: str = ""
        CYAN: str = ""
    
    class ANTINUKE:
        ENABLED: str = ""
        DISABLE: str = ""
        
    class BADGES:
        SERVER_OWNER: str = "<:server_owner:1423366267573637302>"
        
    class TICKETS:
        TRASH: str = "<:trash:1423751023842955385>"
        
    class MISC:
        CONNECTION: str = "<:connection:1423366043958771922>"
        CRYPTO: str = "<:crypto:1423750202195705966>"
        BITCOIN: str = "<:bitcoin:1423749258573774970>"
        ETHEREUM: str = "<:ethereum:1423749684194705520>"
        LITECOIN: str = "<:litecoin:1423750291429527734>"
        XRP: str = "<:xrp:1423750848873496618>"
        AI: str = ""
        EXTRA_SUPPORT: str = ""
        ANAYLTICS: str = ""
        SECURITY: str = ""
        REDUCED_COOLDOWNS: str = ""
        MODERATION: str = ""
        COMMANDS: str = ""
        
    class FUN:
        GAY: str = ""
        LESBIAN: str = ""
        DUMBASS: str = ""
        
    class SOCIAL:
        DISCORD: str = "<:discord:1423443912793657344>"
        WEBSITE: str = "<:website:1423442144776949911>"
        GITHUB: str = "<:github:1423437308081733702>"
        
    class ECONOMY:
        WELCOME: str = ""
        GEM: str = ""
        CROWN: str = ""
        INVIS: str = ""
        
    class AUDIO:
        PREVIOUS: str = "<:sp_previous:1424090755030454284>"
        PAUSE: str = "<:sp_pause:1424091848900739213>"
        RESUME: str = "<:sp_resume:1424169876544819262>"
        SKIP: str = "<:sp_next:1424090799355986021>"
        REPEAT: str = "<:sp_repeat:1424090908365946982>"
        REPEAT_TRACK: str = ""
        QUEUE: str = "<:queue:1469695803005079583>"
        
    class CONTEXT:
        APPROVE: str = "<:approve:1455782858370322553>"
        DENY: str = "<:deny:1455782784818872381>"
        WARN: str = "<:warn:1455782935906095217>"
        LEFT: str = "<:previous:1427025073587355768>"
        RIGHT: str = "<:next:1427025026858749983>"
        NAVIGATE: str = ""
        JUUL: str = ""
        
    class POLL:
        WHITE: str = ""
        WLR: str = ""
        WRR: str = ""
        BLR: str = ""
        BRR: str = ""
        SQUARE: str = ""
        
    class STAFF:
        DEVELOPER: str = ""
        OWNER: str = ""
        SUPPORT: str = ""
        TRIAL: str = ""
        MODERATOR: str = ""
        DONOR: str = ""
        INSTANCE: str = ""
        STAFF: str = "<:staff:1423372682430251138>"

        
    class INTERFACE:
        LOCK: str = "<:vm_lock:1423361217891799140>"
        UNLOCK: str = "<:vm_unlock:1423361237516947556>"
        GHOST: str = "<:vm_ghost:1427839064064786487>"
        REVEAL: str = "<:vm_reveal:1427840174607433880>"
        CLAIM: str = "<:vc_claim:1427840707716059176>"
        DISCONNECT: str = "<:vm_disconnect:1427013718679621733>"
        ACTIVITY: str = "<:vm_activities:1423374608987455548>"
        INFORMATION: str = "<:vm_info:1427011288575246367>"
        INCREASE: str = "<:vm_increase:1424064290985345086>"
        DECREASE: str = "<:vm_decrease:1427013412176662689>"
        

class AUTHORIZATION:
    OPENAI: str = "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"
    JEYY_API: str = "74PJCE1J60PJ4CHN70P38C1K6OP3G.CLR6IORKEDLMIP0.C8m29OywqHgCNiZoOMDlqg"
    LOVENSE: str = "47WvqON2D9RDVfd8Tv7BJ2dXs-95Kwaws7AriGUdpH5_zl_aKLBzTVPiqQFQPNri"
    KRAKEN: str = "MWEzMmE1YjJlNDQ0YjFjMRfCh9dBng0CbbxTTVG-KsbYhsMtiWD6lucki4tbq3L2"
    FERNET_KEY: str = "Ye0cdyst0iGNFo7vlvfyjZx7fBsNnzu0Xc7m5wHIavo="
    WEATHER: str = "6a3ab4420afb487794d171848253009"
    WOLFRAM: str = "29HHK82X4Q"
    FNBR: str = "f6cb0c25-d707-42a4-b1e2-e0df4bed159e"
    PIPED_API: str = "pipedapi.adminforge.de"
    SOUNDCLOUD: str = ""
    OSU: str = "a64dd995fcfb3754bb734f7a80fe13168be51879"
    TOPGG: str = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfdCI6Ijc4NTE0MDI1MjI3MTA1MDc1MiIsImlkIjoiNzU4ODg5MTMyMzUyMzcyNzM2IiwiaWF0IjoxNzY1MDI4ODIzfQ.scL2Ion0w1MsclhC3kiPGnb5QC7pLJZWuUu--fXo8R0"
    TOPGG_AUTH: str = "4%rJk^tT#p5Ky%95G79$&na$6&pmaMAx"
    
    class REDDIT:
        CLIENT_ID: str = "7s2HJa0My0keJAiLvFhvZQ"
        CLIENT_SECRET: str = "C2oX-F-4uR6r4q_6RvUq8LRLrqsR8g"
        
    class LASTFM: 
        KEY: str = "4b25716d870cfa49dce73170b5d67439"
        SECRET: str = "f3384c0ce4269dd575ac597347747b3c"
        
    class TWITCH:
        CLIENT_ID: str = "jzkbprff40iqj646a697cyrvl0zt2m3"
        CLIENT_SECRET: str = "zj8b3n1t9m6b4g4f6vd5p3l4w1x9y0"
    class INTERNAL:
        API_KEY: str = "ShHdce3nXXaYmQ5PzBNKKsbtRoamqYc"
        CALLBACK: str = "ekNbnGizmHtne3kapiod9GacoKABt3"
        SPECIAL: str = "tgRJjgKjai6Eke4QdGc3xtjgXkbicX9"
        SECRET: str = "verymuchasecretforwarmlatbotfr"

class LOGGER:
    GUILD_JOIN_LOGGER: int = 1421685971308773447
    GUILD_BLACKLIST_LOGGER: int = 1421685251792441375
    USER_BLACKLIST_LOGGER: int = 1421686092394135562

class CLIENT:
    TOKEN: str = "MTQyMDYwOTM0MzI4MzUzMTc3Ng.GQEKAY.EODx61H_2en7AxzCToRJdbpCzR5K41hdf_xpVQ"
    PREFIX: str = ","
    SHARDS: int = 2
    INVITE_URL: str = "https://discord.com/api/oauth2/authorize?client_id=1420609343283531776&permissions=8&scope=bot%20applications.commands"
    SUPPORT_URL: str = "https://discord.gg/apply"
    #TWITCH_URL: str = "https://twitch.tv/nxyyontop"
    OWNER_IDS: list = [1137513168965476352]
    DESCRIPTION: str = "A bot to manage your Discord server."

class LAVALINK:
    NODE_COUNT: int = 2
    HOST: str = "expel.best"
    PORT: int = 443
    PASSWORD: str = "publicnodeaccessforallthatneednotwant"
    SPOTIFY_CLIENT_ID: str = "4c3c2ba7ad6c4ef4a0c0d793cb979ce8"
    SPOTIFY_CLIENT_SECRET: str = "12dd934e7bca4536bb9f8d86b049a25e"
    
class RATELIMITS:
    PER_10S: int = 10
    PER_30S: int = 25
    PER_1M: int = 50

class CLOUDFLARE:
    
    class R2:
        ENDPOINT: str = "https://72517b1ad2f1c7ffb8488e7ae9b1e317.r2.cloudflarestorage.com"
        ACCESS_KEY: str = "05b1a9daca6f61fc7910b1f7b94dbbe4"
        ACCESS_SECRET: str = "8658e134fde10e369290bacce548c8c377b87da3a399bacb7158f92c07b116ac"
        BUCKET: str = "warm"

class DATABASE:
    DSN: str = "postgresql://postgres:puhzwjesauvz3mir@warm-db-tuhfga:5432/postgres"
    REDIS: str = "redis://default:zulqlpzsdxreypju@warm-cache-cbte4a:6379"

class POSTHOG:
    TRACK_SELF: bool = False
    
class NETWORK:
    HOST: str = "0.0.0.0"
    PORT: int = 9562