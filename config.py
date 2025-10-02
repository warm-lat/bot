class EMOJIS:
    
    class AUDIO:
        PREVIOUS: str = ""
        PAUSE: str = ""
        SKIP: str = ""
        REPEAT: str = ""
        REPEAT_TRACK: str = ""
        RESUME: str = ""
        QUEUE: str = ""
    
    class TICKETS:
        TRASH: str = ""
        
    class CONTEXT:
        APPROVE: str = ""
        DENY: str = ""
        WARN: str = ""
        LEFT: str = ""
        RIGHT: str = ""
        FILTER: str = ""
    
    class SOCIAL:
        DISCORD: str = ""
        WEBSITE: str = ""
        GITHUB: str = ""
    
    class MISC:
        CONNECTION: str = ""
        
    class POLL:
        WHITE: str = ""
        WLR: str = ""
        WRR: str = ""
        BLR: str = ""
        BRR: str = ""
        SQUARE: str = ""
        
    class BADGES:
        SERVER_OWNER: str = ""
        
    class STAFF:
        DEVELOPER: str = ""
        OWNER: str = ""
        SUPPORT: str = ""
        TRIAL: str = ""
        MODERATOR: str = ""
        DONOR: str = ""
        INSTANCE: str = ""
        STAFF: str = ""
        
    class SPOTIFY:
        ICON: str = ""
        LEFT: str = ""
        RIGHT: str = ""
        BLACK: str = ""
        WHITE: str = ""
        BLACK_RIGHT: str = ""
        EXPLCIT: str = ""
        LISTENING: str = ""
        SHUFFLE: str = ""
        REPEAT: str = ""
        DEVICE: str = ""
        FAVORITE: str = ""
        REMOVE: str = ""
        

class AUTHORIZATION:
    OPENAI: str = "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"
    JEYY_API: str = "74PJCE1J60PJ4CHN70P38C1K6OP3G.CLR6IORKEDLMIP0.C8m29OywqHgCNiZoOMDlqg"
    LOVENSE: str = "47WvqON2D9RDVfd8Tv7BJ2dXs-95Kwaws7AriGUdpH5_zl_aKLBzTVPiqQFQPNri"
    KRAKEN: str = "MWEzMmE1YjJlNDQ0YjFjMRfCh9dBng0CbbxTTVG-KsbYhsMtiWD6lucki4tbq3L2"
    FERNET_KEY: str = "Ye0cdyst0iGNFo7vlvfyjZx7fBsNnzu0Xc7m5wHIavo="
    WEATHER: str = "6a3ab4420afb487794d171848253009"
    WOLFRAM: str = ""
    
    class REDDIT:
        CLIENT_ID: str = "7s2HJa0My0keJAiLvFhvZQ"
        CLIENT_SECRET: str = "C2oX-F-4uR6r4q_6RvUq8LRLrqsR8g"
    
class LASTFM:
    API_KEY: str = "4b25716d870cfa49dce73170b5d67439"
    API_SECRET: str = "f3384c0ce4269dd575ac597347747b3c"

class COLORS:
    NEUTRAL: int = 0x2F3136
    APPROVE: int = 0x57F287
    DENY: int = 0xED4245
    WARN: int = 0xFEE75C
    SPOTIFY: int = 0x1ED760

class LOGGER:
    GUILD_JOIN_LOGGER: int = 1421685971308773447
    GUILD_BLACKLIST_LOGGER: int = 1421685251792441375
    USER_BLACKLIST_LOGGER: int = 1421686092394135562

class CLIENT:
    PREFIX: str = ","
    INVITE_URL: str = "https://discord.com/api/oauth2/authorize?client_id=1420609343283531776&permissions=8&scope=bot%20applications.commands"
    SUPPORT_URL: str = "https://discord.gg/warm"
    TWITCH_URL: str = "https://twitch.tv/nxyyontop"
    OWNER_IDS: list = [1137513168965476352]
    DESCRIPTION: str = "A bot to manage your Discord server."
    

class LAVALINK:
    NODE_COUNT: int = 2
    HOST: str = "lavalink.expel.best"
    PORT: int = 2333
    PASSWORD: str = "youwillnotpass"
    SPOTIFY_CLIENT_ID: str = "4c3c2ba7ad6c4ef4a0c0d793cb979ce8"
    SPOTIFY_CLIENT_SECRET: str = "12dd934e7bca4536bb9f8d86b049a25e"
    
class RATELIMITS:
    PER_10S: int = 10
    PER_30S: int = 35
    PER_1M: int = 75

class CLOUDFLARE:
    
    class SAAS:
        TOKEN: str = "bjx2pf443xBAEaA6IfQ2XeKPwu4YSeE1YVHz2zbC"
        ZONE: str = "8bd322a1c8ed171d1d4462f471735b2d"

class DATABASE:
    DSN: str = "postgresql://evictskid:qq3gpcgksmtj9ckg@warm-db-70f72q:5432/warm"
    REDIS: str = "redis://default:jqcnpzlwlpqll4do@warm-cache-lihrnx:6379"

class POSTHOG:
    TRACK_SELF: bool = False

class DISCORD:
    TOKEN: str = "MTQyMDYwOTM0MzI4MzUzMTc3Ng.G7Mk1E.nwns-aEzbAQFYK7UXCDpz2L3peMfYhroxYgujU"
    
class NETWORK:
    HOST: str = "0.0.0.0"
    PORT: int = 9562