class EMOJIS:
    
    class AUDIO:
        PREVIOUS: str = ""
    
    class TICKETS:
        TRASH: str = ""
        
    class CONTEXT:
        APPROVE: str = ""
        DENY: str = ""
        WARN: str = ""
        
        

class AUTHORIZATION:
    OPENAI: str = "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"
    JEYY_API: str = "74PJCE1J60PJ4CHN70P38C1K6OP3G.CLR6IORKEDLMIP0.C8m29OywqHgCNiZoOMDlqg"
    LOVENSE: str = "47WvqON2D9RDVfd8Tv7BJ2dXs-95Kwaws7AriGUdpH5_zl_aKLBzTVPiqQFQPNri"
    KRAKEN: str = ""
    FERNET_KEY: str = "Ye0cdyst0iGNFo7vlvfyjZx7fBsNnzu0Xc7m5wHIavo="
    
    class REDDIT:
        CLIENT_ID: str = "7s2HJa0My0keJAiLvFhvZQ"
        CLIENT_SECRET: str = "C2oX-F-4uR6r4q_6RvUq8LRLrqsR8g"
    
    

class COLORS:
    NEUTRAL: int = 0x2F3136

    
class CLIENT:
    PREFIX: str = ","
    INVITE_URL: str = "https://discord.com/api/oauth2/authorize?client_id=1420609343283531776&permissions=8&scope=bot%20applications.commands"
    SUPPORT_URL: str = "https://discord.gg/warm"
    TWITCH_URL: str = "https://twitch.tv/nxyyontop"
    OWNER_IDS: list = [1137513168965476352]
    DESCRIPTION: str = "A bot to manage your Discord server."
    WARP: str = "http://127.1:40000"
    

class LAVALINK:
    NODE_COUNT: int = 1
    HOST: str = "lavalink.expel.best"
    PORT: int = 8080
    PASSWORD: str = "youwillnotpass"
    SPOTIFY_CLIENT_ID: str = "your_spotify_client_id"
    SPOTIFY_CLIENT_SECRET: str = "your_spotify_client_secret"
    
class RATELIMITS:
    PER_10S: int = 10
    PER_30S: int = 35
    PER_1M: int = 75

class DATABASE:
    DSN: str = "postgresql://evictskid:qq3gpcgksmtj9ckg@warm-db-70f72q:5432/warm"
    REDIS: str = "redis://default:jqcnpzlwlpqll4do@warm-cache-lihrnx:6379"

class DISCORD:
    TOKEN: str = "MTQyMDYwOTM0MzI4MzUzMTc3Ng.G7Mk1E.nwns-aEzbAQFYK7UXCDpz2L3peMfYhroxYgujU"
    
class NETWORK:
    HOST: str = "0.0.0.0"
    PORT: int = 9562