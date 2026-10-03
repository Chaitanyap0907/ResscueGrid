```
CASE STUDY 2 – RescueGrid
```

```
Project: RescueGrid: A Flutter-Based Mobile Application for Real-Time Campus
Emergency Reporting and Response
```

# `Problem Statement` 

```
Campus emergencies may happen at the same time. Manual dispatch by phone can be
slow, inconsistent and difficult to audit. The application should allow students
to report emergencies quickly with GPS location, category, photograph and
optional description, while helping authorized responders receive assignments,
navigate to incidents, update response status and request backup.
```

# `Proposed Application` 

```
RescueGrid is a Flutter cross-platform application with separate student and
responder interfaces. An administrative command center can be implemented as a
web dashboard or additional role-based interface. A severity engine classifies
incidents and a dispatch engine ranks available responders using severity, skill
match, distance/estimated arrival time and current workload.
Application Workflow
```

```
Student Reports Emergency with GPS Severity Engine Responder Ranking Auto-
Assignment Live Tracking Incident Resolved Timeline Archived
```

```
Modules:
```

```
Requirement
User Authentication
```

```
Campus SSO or OAuth2 login with role-based access for students, responders and
administrators.
```

# `Emergency Reporting` 

```
Quick SOS reporting with GPS location, incident category, photograph and
optional description.
```

# `Severity Assessment` 

```
Classify incidents using category, keywords, number of people affected, time of
day and location risk.
```

# `Responder Management` 

```
Maintain responder type, skills, duty status, live location and current
workload.
```

# `Automatic Assignment` 

```
Rank available responders using severity, skill match, distance/ETA and
availability.
```

```
Navigation and Routing
```

```
Show incident location and support route and estimated arrival time.
```

# `Incident Tracking` 

```
Display incident status and responder progress in real time.
```

# `Escalation Management` 

```
Reassign unaccepted incidents to the next candidate and alert the command center
when required.
```

# `Notifications` 

```
Push alerts for assignments, escalations and incident status changes.
```

```
Command Center
```

```
Incident monitoring, manual assignment override, filters and statistics.
```

# `Incident Timeline` 

```
Chronological record of reporting, scoring, assignment, acceptance, arrival and
resolution.
```

```
Recommended Core Scope for the Contest
```

- `Flutter-based student and responder mobile interfaces.` 

- `Secure login and role-based access.` 

- `Emergency reporting with category, photo and GPS location.` 

- `Responder availability and assignment acceptance or decline.` 

- `Real-time incident status updates using WebSockets or an appropriate real-time service.` 

- `Map display and navigation to the incident location.` 

- `Push notifications for assignments and status changes.` 

- `Incident resolution updates and a basic event timeline.` 

# `Expected Outcomes` 

- `Quick emergency reporting with GPS location, category, photograph and optional description.` 

- `Real-time incident and responder status updates.` 

- `Responder assignment support based on severity, skills, distance/ETA and availability.` 

- `Push notifications for assignments, escalations and status changes.` 

- `Navigation support for responders.` 

- `Incident timeline for monitoring and review.` 

- `Administrative interface for monitoring incidents and managing response activities.` 

