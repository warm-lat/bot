from typing import Optional, Any, List, Dict
from pydantic import BaseModel
from discord import Embed
from datetime import datetime
import config, logging, aiohttp, asyncio

log = logging.getLogger(__name__)

CONFIG = {
    "github_allowed_repos": [
        "warm-lat/bot",
        "warm-lat/web",
    ],
    "token": config.CLIENT.TOKEN, 
    "updates_channel_id": 1424543580869103648
}

class Owner(BaseModel):
    name: Optional[str] = None
    email: Optional[Any] = None
    login: Optional[str] = None
    id: Optional[int] = None
    node_id: Optional[str] = None
    avatar_url: Optional[str] = None
    gravatar_id: Optional[str] = None
    url: Optional[str] = None
    html_url: Optional[str] = None
    followers_url: Optional[str] = None
    following_url: Optional[str] = None
    gists_url: Optional[str] = None
    starred_url: Optional[str] = None
    subscriptions_url: Optional[str] = None
    organizations_url: Optional[str] = None
    repos_url: Optional[str] = None
    events_url: Optional[str] = None
    received_events_url: Optional[str] = None
    type: Optional[str] = None
    user_view_type: Optional[str] = None
    site_admin: Optional[bool] = None

class License(BaseModel):
    key: Optional[str] = None
    name: Optional[str] = None
    spdx_id: Optional[str] = None
    url: Optional[str] = None
    node_id: Optional[str] = None

class Repository(BaseModel):
    id: Optional[int] = None
    node_id: Optional[str] = None
    name: Optional[str] = None
    full_name: Optional[str] = None
    private: Optional[bool] = None
    owner: Optional[Owner] = None
    html_url: Optional[str] = None
    description: Optional[Any] = None
    fork: Optional[bool] = None
    url: Optional[str] = None
    forks_url: Optional[str] = None
    keys_url: Optional[str] = None
    collaborators_url: Optional[str] = None
    teams_url: Optional[str] = None
    hooks_url: Optional[str] = None
    issue_events_url: Optional[str] = None
    events_url: Optional[str] = None
    assignees_url: Optional[str] = None
    branches_url: Optional[str] = None
    tags_url: Optional[str] = None
    blobs_url: Optional[str] = None
    git_tags_url: Optional[str] = None
    git_refs_url: Optional[str] = None
    trees_url: Optional[str] = None
    statuses_url: Optional[str] = None
    languages_url: Optional[str] = None
    stargazers_url: Optional[str] = None
    contributors_url: Optional[str] = None
    subscribers_url: Optional[str] = None
    subscription_url: Optional[str] = None
    commits_url: Optional[str] = None
    git_commits_url: Optional[str] = None
    comments_url: Optional[str] = None
    issue_comment_url: Optional[str] = None
    contents_url: Optional[str] = None
    compare_url: Optional[str] = None
    merges_url: Optional[str] = None
    archive_url: Optional[str] = None
    downloads_url: Optional[str] = None
    issues_url: Optional[str] = None
    pulls_url: Optional[str] = None
    milestones_url: Optional[str] = None
    notifications_url: Optional[str] = None
    labels_url: Optional[str] = None
    releases_url: Optional[str] = None
    deployments_url: Optional[str] = None
    created_at: Optional[int] = None
    updated_at: Optional[str] = None
    pushed_at: Optional[int] = None
    git_url: Optional[str] = None
    ssh_url: Optional[str] = None
    clone_url: Optional[str] = None
    svn_url: Optional[str] = None
    homepage: Optional[Any] = None
    size: Optional[int] = None
    stargazers_count: Optional[int] = None
    watchers_count: Optional[int] = None
    language: Optional[str] = None
    has_issues: Optional[bool] = None
    has_projects: Optional[bool] = None
    has_downloads: Optional[bool] = None
    has_wiki: Optional[bool] = None
    has_pages: Optional[bool] = None
    has_discussions: Optional[bool] = None
    forks_count: Optional[int] = None
    mirror_url: Optional[Any] = None
    archived: Optional[bool] = None
    disabled: Optional[bool] = None
    open_issues_count: Optional[int] = None
    license: Optional[License] = None
    allow_forking: Optional[bool] = None
    is_template: Optional[bool] = None
    web_commit_signoff_required: Optional[bool] = None
    topics: Optional[List] = None
    visibility: Optional[str] = None
    forks: Optional[int] = None
    open_issues: Optional[int] = None
    watchers: Optional[int] = None
    default_branch: Optional[str] = None
    stargazers: Optional[int] = None
    master_branch: Optional[str] = None
    organization: Optional[str] = None
    custom_properties: Optional[Dict[str, Any]] = None

class Pusher(BaseModel):
    name: Optional[str] = None
    email: Optional[str] = None

class Organization(BaseModel):
    login: Optional[str] = None
    id: Optional[int] = None
    node_id: Optional[str] = None
    url: Optional[str] = None
    repos_url: Optional[str] = None
    events_url: Optional[str] = None
    hooks_url: Optional[str] = None
    issues_url: Optional[str] = None
    members_url: Optional[str] = None
    public_members_url: Optional[str] = None
    avatar_url: Optional[str] = None
    description: Optional[str] = None

class Sender(BaseModel):
    login: Optional[str] = None
    id: Optional[int] = None
    node_id: Optional[str] = None
    avatar_url: Optional[str] = None
    gravatar_id: Optional[str] = None
    url: Optional[str] = None
    html_url: Optional[str] = None
    followers_url: Optional[str] = None
    following_url: Optional[str] = None
    gists_url: Optional[str] = None
    starred_url: Optional[str] = None
    subscriptions_url: Optional[str] = None
    organizations_url: Optional[str] = None
    repos_url: Optional[str] = None
    events_url: Optional[str] = None
    received_events_url: Optional[str] = None
    type: Optional[str] = None
    user_view_type: Optional[str] = None
    site_admin: Optional[bool] = None

class Author(BaseModel):
    name: Optional[str] = None
    email: Optional[str] = None
    username: Optional[str] = None

class Committer(BaseModel):
    name: Optional[str] = None
    email: Optional[str] = None
    username: Optional[str] = None

class Commit(BaseModel):
    id: Optional[str] = None
    tree_id: Optional[str] = None
    distinct: Optional[bool] = None
    message: Optional[str] = None
    timestamp: Optional[str] = None
    url: Optional[str] = None
    author: Optional[Author] = None
    committer: Optional[Committer] = None
    added: Optional[List] = None
    removed: Optional[List] = None
    modified: Optional[List[str]] = None

class HeadCommit(BaseModel):
    id: Optional[str] = None
    tree_id: Optional[str] = None
    distinct: Optional[bool] = None
    message: Optional[str] = None
    timestamp: Optional[str] = None
    url: Optional[str] = None
    author: Optional[Author] = None
    committer: Optional[Committer] = None
    added: Optional[List] = None
    removed: Optional[List] = None
    modified: Optional[List[str]] = None

class GithubPushEvent(BaseModel):
    ref: Optional[str] = None
    before: Optional[str] = None
    after: Optional[str] = None
    repository: Optional[Repository] = None
    pusher: Optional[Pusher] = None
    organization: Optional[Organization] = None
    sender: Optional[Sender] = None
    created: Optional[bool] = None
    deleted: Optional[bool] = None
    forced: Optional[bool] = None
    base_ref: Optional[Any] = None
    compare: Optional[str] = None
    commits: Optional[List[Commit]] = None
    head_commit: Optional[HeadCommit] = None
    
    @property
    def to_embed(self) -> Embed:
        if not self.head_commit:
            return None
            
        added_count = len(self.head_commit.added or [])
        deleted_count = len(self.head_commit.removed or [])
        modified_count = len(self.head_commit.modified or [])

        # Construct each part of the message based on conditions
        added_message = (
            f"+ Added {added_count} {'files' if added_count > 1 else 'file'}"
            if added_count > 0
            else ""
        )
        deleted_message = (
            f"- Deleted {deleted_count} {'files' if deleted_count > 1 else 'file'}"
            if deleted_count > 0
            else ""
        )
        modified_message = (
            f"! Modified {modified_count} {'files' if modified_count > 1 else 'file'}"
            if modified_count > 0
            else ""
        )

        # Combine non-empty parts with newlines
        change_message = "\n".join(
            filter(None, [added_message, deleted_message, modified_message])
        )

        branch = self.ref.split('/')[-1]
        commit_count = len(self.commits or [])
        
        description = (
            f">>> There has been **{commit_count}** {'commit' if commit_count == 1 else 'commits'} "
            f"to [`{self.repository.full_name}`]({self.repository.html_url}/tree/{branch})\n"
            f"```diff\n{change_message}\n```"
        )

        embed = Embed(
            title=f"New {'Commit' if commit_count == 1 else 'Commits'} to {self.repository.name} ({branch})",
            url=self.compare,  
            description=description,
            color=0x2ea043  
        )

        valid_commit = False
        for commit in (self.commits or []):
            if commit.message and len(commit.message.strip()) >= 5:
                valid_commit = True
                commit_url = f"{self.repository.html_url}/commit/{commit.id}"
                embed.add_field(
                    name=f"{commit.id[:7]}",
                    value=f"[View Commit]({commit_url})\n```fix\n{commit.message.strip()}\n```",
                    inline=False,
                )

        if not valid_commit:
            return None

        if self.sender:
            embed.set_author(
                name=str(self.sender.login),
                icon_url=str(self.sender.avatar_url),
                url=str(self.sender.html_url)
            )
            
        embed.set_footer(
            text=f"📁 {self.repository.size or 0}KB | 📝 {self.repository.open_issues_count or 0} issues | 👥 {self.repository.watchers_count or 0} watchers",
            icon_url="https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png"
        )
            
        embed.timestamp = datetime.now()
        return embed
    
    async def send_message(self):
        if not (embed := self.to_embed):
            return
        log.info(f"Received embed: {embed}")
        channel_id = CONFIG["updates_channel_id"]
        token = CONFIG["token"]
        for _ in range(5):
            try:
                async with aiohttp.ClientSession() as session:
                    async with session.post(
                        f"https://discord.com/api/v10/channels/{channel_id}/messages",
                        headers={
                            "Authorization": f"Bot {token}",
                            "Content-Type": "application/json"
                        },
                        json={"embeds": [embed.to_dict()]}
                    ) as response:
                        if response.status == 200:
                            return await response.json()
                        
                        if response.status != 429:
                            log.error(f"Failed to send message: {response.status}")
                            
                await asyncio.sleep(1)
                        
            except Exception as e:
                log.error(f"Error sending message: {e}")
                await asyncio.sleep(1)