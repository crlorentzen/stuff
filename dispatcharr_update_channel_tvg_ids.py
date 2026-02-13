#!/usr/bin/env python3
"""
Script to authenticate with Dispatcharr API and update channel tvg_id values.
Sets tvg_id to: channel_number + channel_name
"""

import requests
import sys
from typing import Optional


class DispatcharrAPI:
    def __init__(self, base_url: str):
        self.base_url = base_url.rstrip('/')
        self.access_token: Optional[str] = None
        self.session = requests.Session()
    
    def authenticate(self, username: str, password: str) -> bool:
        """
        Authenticate with the API and store the access token.
        
        Args:
            username: API username
            password: API password
            
        Returns:
            True if authentication successful, False otherwise
        """
        url = f"{self.base_url}/api/accounts/token/"
        payload = {
            "username": username,
            "password": password
        }
        
        try:
            response = self.session.post(url, json=payload)
            response.raise_for_status()
            
            data = response.json()
            self.access_token = data.get('access')
            
            if self.access_token:
                self.session.headers.update({
                    'Authorization': f'Bearer {self.access_token}'
                })
                print(f"✓ Authentication successful for user: {username}")
                return True
            else:
                print("✗ Authentication failed: No access token received")
                return False
                
        except requests.exceptions.RequestException as e:
            print(f"✗ Authentication failed: {e}")
            return False
    
    def get_channels(self, page_size: int = 100) -> list:
        """
        Retrieve all channels from the API with pagination.
        
        Args:
            page_size: Number of results per page
            
        Returns:
            List of all channel objects
        """
        url = f"{self.base_url}/api/channels/channels/"
        all_channels = []
        page = 1
        
        while True:
            params = {
                'page': page,
                'page_size': page_size
            }
            
            try:
                response = self.session.get(url, params=params)
                response.raise_for_status()
                
                data = response.json()
                channels = data.get('results', [])
                
                if not channels:
                    break
                
                all_channels.extend(channels)
                print(f"  Retrieved page {page} ({len(channels)} channels)")
                
                # Check if there are more pages
                if not data.get('next'):
                    break
                    
                page += 1
                
            except requests.exceptions.RequestException as e:
                print(f"✗ Error retrieving channels: {e}")
                break
        
        print(f"✓ Retrieved {len(all_channels)} total channels")
        return all_channels
    
    def update_channel(self, channel_id: int, tvg_id: str) -> bool:
        """
        Update a channel's tvg_id.
        
        Args:
            channel_id: The channel ID
            tvg_id: The new tvg_id value
            
        Returns:
            True if update successful, False otherwise
        """
        url = f"{self.base_url}/api/channels/channels/{channel_id}/"
        payload = {
            "tvg_id": tvg_id
        }
        
        try:
            response = self.session.patch(url, json=payload)
            response.raise_for_status()
            return True
        except requests.exceptions.RequestException as e:
            print(f"  ✗ Failed to update channel {channel_id}: {e}")
            return False


def main():
    # Configuration
    BASE_URL = input("Enter API base URL (e.g., http://localhost:8000): ").strip()
    USERNAME = input("Enter username: ").strip()
    PASSWORD = input("Enter password: ").strip()
    
    if not all([BASE_URL, USERNAME, PASSWORD]):
        print("✗ Error: All fields are required")
        sys.exit(1)
    
    # Initialize API client
    api = DispatcharrAPI(BASE_URL)
    
    # Authenticate
    print("\n1. Authenticating...")
    if not api.authenticate(USERNAME, PASSWORD):
        sys.exit(1)
    
    # Get all channels
    print("\n2. Retrieving channels...")
    channels = api.get_channels()
    
    if not channels:
        print("No channels found")
        sys.exit(0)
    
    # Update each channel's tvg_id
    print(f"\n3. Updating tvg_id for {len(channels)} channels...")
    success_count = 0
    skip_count = 0
    
    for channel in channels:
        channel_id = channel.get('id')
        channel_number = channel.get('channel_number')
        channel_name = channel.get('name', '')
        
        # Skip if channel_number is None
        if channel_number is None:
            print(f"  ⊘ Skipping channel {channel_id} '{channel_name}' (no channel number)")
            skip_count += 1
            continue
        
        # Create new tvg_id: channel_number + channel_name
        new_tvg_id = f"{channel_number}{channel_name}"
        
        # Update the channel
        if api.update_channel(channel_id, new_tvg_id):
            print(f"  ✓ Updated channel {channel_id}: '{channel_name}' → tvg_id: '{new_tvg_id}'")
            success_count += 1
        else:
            print(f"  ✗ Failed to update channel {channel_id}")
    
    # Summary
    print(f"\n{'='*60}")
    print(f"Summary:")
    print(f"  Total channels: {len(channels)}")
    print(f"  Successfully updated: {success_count}")
    print(f"  Skipped (no channel number): {skip_count}")
    print(f"  Failed: {len(channels) - success_count - skip_count}")
    print(f"{'='*60}")


if __name__ == "__main__":
    main()
