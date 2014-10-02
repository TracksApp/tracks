* [Installation »](installation.md)
* [Upgrading »](upgrading.md)

## Introduction

Tracks is a web application that is specifically designed to implement the Getting Things Done™ (GTD) methods. That doesn't mean that you can't use it for other kinds of todo tracking. Data is stored in a database (either MySQL, Postgresql or SQLite), and viewed in a web browser via a web server (Apache, Lighttpd or Mongrel among others). This makes it cross-platform as well as being accessible from anywhere that you have web access.

Using the GTD method as a model, there are three main components to Tracks: Next actions, Contexts and Projects.

* **Next Actions**: These are the heart of GTD. They are the very next physical action that can be taken on something. It's best to phrase these in an active way e.g. "Call Bob about the committee meeting" or "Search for a reputable garage".
* **Contexts**: Contexts are very flexible, and can be places, states of mind or modes of working in which actions can be taken. Next actions can be assigned to and sorted by context so that you know when you are able to make progress with items. e.g. "Library", "Shops" or "Tired".
* **Projects**: any goal which requires more than one next action to take it to completion is a Project. In Tracks, you can view your next actions by Project.

Tracks has been thoroughly beta tested by a large number of people, and should be fully stable for everyday use. However, once set up, Tracks will contain the majority of your plans for your work and personal life, so it's only sensible to make sure that you have frequent, reliable backups of your data. Full changenotes on the release can be found in `doc/CHANGELOG`.
