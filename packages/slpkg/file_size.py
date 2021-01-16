#!/usr/bin/python3
# -*- coding: utf-8 -*

# file_size.py file is part of slpkg.

# Copyright 2014-2021 Dimitris Zlatanidis <d.zlatanidis@gmail.com>
# All rights reserved.

# Slpkg is a user-friendly package manager for Slackware installations

# https://gitlab.com/dslackw/slpkg

# Slpkg is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.


import os
import urllib3
import requests

from slpkg.__metadata__ import MetaData as _meta_


class FileSize:
    """Check local or remote file size
    """
    def __init__(self, registry):
        self.meta = _meta_
        self.registry = registry
        if self.meta.http_proxy:
            self.http = urllib3.ProxyManager(self.meta.http_proxy)
        else:
            #self.http = urllib3.PoolManager()
            self.s = requests.Session()

    def server(self):
        """Returns the size of remote files
        """
        try:
            #r = self.http.request("GET", self.registry)
            r = self.s.get(self.registry, timeout=20, stream=True, headers={'Accept-Encoding': None})
            return int(r.headers["Content-Length"])
        #except urllib3.exceptions.NewConnectionError:
        except:
            return " "

    def local(self):
        """Returns the size of local files
        """
        return os.path.getsize(self.registry)
