from tools import CompositeMetaClass

from .alias import Alias
from .appeal import Appeal
from .backup import Backup
from .boosterrole import BoosterRole
from .command import CommandManagement
from .confess import Confess
from .customize import Customize
from .disboard import Disboard
from .gallery import Gallery
from .info import Info
from .invites import Invites
from .joindm import JoinDM
from .level import Level
from .logging import Logging
from .porn import Porn
from .publisher import Publisher
from .recording import Recording
from .roles import Roles
from .security import AntiNuke, AntiRaid
from .starboard import Starboard
from .statistics import Statistics
from .sticky import Sticky
from .suggest import Suggest
from .system import System
from .thread import Thread
from .ticket import Ticket
from .timer import Timer
from .trigger import Trigger
from .vanity import Vanity
# from ....archive.verification import Verification
from .webhook import Webhook
# from ....archive.whitelist import Whitelist

class Extended(
    Alias,
    Appeal,
    AntiNuke,
    AntiRaid,
    Backup,
    BoosterRole,
    CommandManagement,
    Confess,
    Customize,
    Disboard,
    Gallery,
    Info,
    Invites,
    JoinDM,
    Level,
    Logging,
    #Porn,
    Publisher,
    Recording,
    Roles,
    Starboard,
    Statistics,
    Sticky,
    Suggest,
    System,
    Thread,
    Ticket,
    Timer,
    Trigger,
    Vanity,
    # Verification,
    Webhook,
    # Whitelist,
    metaclass=CompositeMetaClass,
):
    """
    Join all extended config cogs into one.
    """
