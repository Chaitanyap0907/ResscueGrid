# RescueGrid: Flutter UI Implementation Plan

## 1. Project Overview

**Purpose:** RescueGrid replaces slow, inconsistent phone dispatch with a mobile-first emergency reporting and response system. Students report an emergency in seconds, with GPS location, category, photo, and an optional description. The system scores severity, ranks available responders (severity, skill match, distance/ETA, workload), and assigns the best candidate. Responders accept, navigate, and update status. A command center monitors everything and can override assignments.

**Core workflow the UI must tell:**
Student reports (SOS) → severity assigned → responder ranked and auto-assigned → responder accepts (or the incident escalates to the next candidate) → live tracking → resolved → timeline archived.

**UI strategy:** The product has two mobile experiences (student, responder) and one command-center experience (administrator). I recommend building the command center as a **responsive role-based interface in the same Flutter app**, using a side navigation rail on wide screens (Flutter web/desktop/tablet). That avoids a second codebase.

**Where to spend visual effort (in priority order):**
1. Student Home + SOS flow
2. Responder Dashboard + Incoming Assignment screen
3. Responder Navigation/Incident screen
4. Command Center dashboard
5. Incident Tracking and Timeline (the "wow" for evaluators)

---

## 2. User Roles

| Role | Who | Uses the app to | Can see / do |
|---|---|---|---|
| **Student** | Campus students | Report emergencies and track the response | Trigger SOS, pick category, attach photo, confirm GPS, add description; see status, assigned responder, ETA, timeline; view own report history. Cannot see other people's incidents. |
| **Responder** | Security, medical, fire/safety staff | Receive and execute assignments | Toggle duty status; see current workload; accept/decline assignments; view incident details, photo, map, route and ETA; update status (En Route → Arrived → Resolved); request backup; view past responses. |
| **Administrator (Command Center)** | Control room / campus safety officers | Monitor and manage all response activity | Live view of all incidents and responders; filter and search; see severity, scores, and timelines; manually assign/reassign (override); receive escalation alerts; view statistics. |

---

## 3. UI Modules

1. **Authentication:** SSO login with role-based routing.
2. **Emergency Reporting (student):** SOS, category, photo, location, description.
3. **Incident Tracking:** live status, responder info, ETA, timeline (shared across roles).
4. **Responder Operations:** duty status, assignment request, navigation, status updates, backup.
5. **Command Center:** monitoring map, incident list, filters, override, responder roster, statistics.
6. **Notifications:** alerts for assignments, escalations, and status changes.
7. **Profile/History:** per-role history and account.

---

## 4. Screen List

**Shared (3):** Login, Notifications, Profile/Settings

**Student (5 unique):**
1. Student Home (SOS)
2. Report Emergency (one screen with sections)
3. Incident Tracking (status + responder + timeline combined)
4. My Reports (history)
5. Report Submitted confirmation (can be a bottom sheet or a state of Tracking)

**Responder (5 unique):**
1. Responder Dashboard
2. Incoming Assignment (full-screen alert)
3. Active Incident and Navigation (map, route, status updates, backup)
4. Response History
5. Request Backup (bottom sheet, not a screen)

**Administrator (4 unique):**
1. Command Center (dashboard with map, live feed, stats)
2. Incidents list (filters) with Incident Detail panel (timeline + override assignment)
3. Responders roster
4. Statistics (can be a tab inside the dashboard if time is short)

**Total: about 17 screens/surfaces.** Merging notes: tracking and timeline are one screen; status updates and navigation are one screen; the manual assignment override is a bottom sheet/dialog.

---

## 5. Navigation Flow

**Common:** Splash → Login (Campus SSO button) → role-based redirect

**Student** (bottom nav: Home | My Reports | Alerts | Profile)

Login → Home → SOS button / category shortcut → Report Emergency → Confirm & Send → Submitted → Incident Tracking (live status → responder assigned → arrived → resolved) → Resolved summary → My Reports

**Responder** (bottom nav: Dashboard | Active | History | Profile)

Login → Dashboard (go On Duty) → push notification → Incoming Assignment → Accept → Active Incident & Navigation → En Route → Arrived → (optional: Request Backup sheet) → Resolve → Summary → Dashboard

Decline → Dashboard (incident shows as passed to next candidate)

**Administrator** (side rail: Command Center | Incidents | Responders | Statistics)

Login → Command Center → select incident (map pin or feed card) → Incident Detail panel (timeline) → Reassign (override sheet) → Confirm → Timeline updates

Escalation banner → open incident → manual assign

---

## 6. Screen-by-Screen UI Requirements

### 6.1 Login
- **Purpose:** Branded entry via campus SSO, role-based access.
- **Layout:** Full-height screen. Top 40%: deep navy panel with the logo (shield + signal-grid mark), the name "RescueGrid", and the tagline "Faster response. Safer campus." Below: a white rounded-top sheet overlapping the panel.
- **Components:** Primary button "Continue with Campus SSO"; secondary "Sign in with email" (expands email/password fields); small role hint text ("Role is detected from your campus account"); footer with a privacy/terms link.
- **States:** Loading (button spinner), error (inline red message), success (short fade to dashboard).
- **Mock behavior:** A hidden three-chip "Demo role" selector (Student/Responder/Admin) to make demos quick.
- **Destination:** Role dashboard.

### 6.2 Student Home (high visual priority)
- **Purpose:** One-tap emergency access, status at a glance.
- **Layout (top to bottom):**
  1. Header: greeting ("Good evening, Aisha"), campus location chip with a green "GPS active" dot, notification bell with badge.
  2. **Active incident banner** (only when one exists): a status-colored card with a progress strip, ETA, and "Track" action.
  3. **SOS hero:** a large circular red button (about 168 px) with a soft pulse ring and the text "Hold to send SOS". Beneath it: "Or choose an emergency type".
  4. **Category grid** (2×3): Medical, Fire, Security Threat, Accident, Harassment, Other. Each tile has a tinted icon container and label.
  5. **Safety info card:** "Your location is shared only with assigned responders".
  6. **Recent reports:** 2 compact list items with status badges.
- **Actions:** SOS hold (1.5 s with a progress ring) opens Report with the category preselected as "Unspecified emergency"; a category tile opens Report with that category.
- **States:** No active incident, active incident, location permission denied (warning banner with "Enable").

### 6.3 Report Emergency
- **Purpose:** Capture the report fast. One scrolling screen, a sticky bottom CTA.
- **Layout:**
  - AppBar "Report Emergency" with a close button.
  - **Location card:** mini map preview (static image or map widget), address text ("Library Block, Gate 2"), accuracy chip ("±8 m"), "Adjust" text button.
  - **Category selector:** horizontally wrapping choice chips with icons, with the selected one filled.
  - **People affected:** stepper (1 / 2–5 / 5+), segmented control (feeds severity).
  - **Photo:** dashed upload tile with Camera/Gallery; after selection shows a thumbnail with a remove icon.
  - **Description:** multiline field (optional), 200-char counter.
  - **Sticky CTA:** red "Send Emergency Report" with a hint "Responders will be alerted immediately".
- **States:** Validation (category required), sending (button progress), success → Tracking.
- **Destination:** Incident Tracking.

### 6.4 Incident Tracking (high visual priority)
- **Purpose:** Live status, responder info, and timeline in one place.
- **Layout:**
  - Top: map area (about 38% of height) showing the incident pin and, when assigned, the responder pin with a route line. Overlaid floating ETA pill ("Arriving in 4 min").
  - Draggable bottom sheet (snaps to peek/half/full):
    1. Status header: incident ID (#RG-2041), severity badge, status badge.
    2. **Horizontal stepper:** Reported → Assigned → En Route → Arrived → Resolved.
    3. **Responder card:** avatar, name, type (Campus Medic), skills chip, "Call" button.
    4. **Incident summary:** category, photo thumbnail, description.
    5. **Timeline** (vertical, timestamps).
    6. "Cancel report / False alarm" text button (low emphasis).
- **States:** Searching for a responder (animated shimmer + "Finding the nearest responder…"), escalated ("Reassigning to next responder"), resolved (green summary card).

### 6.5 My Reports
- **Layout:** Filter chips (All / Active / Resolved), list of report cards: category icon, title, date/time, location, status badge. Empty state with an illustration and "No reports yet".
- **Navigation:** Card → Incident Tracking (read-only timeline if resolved).

### 6.6 Responder Dashboard (high visual priority)
- **Purpose:** Duty control and operational overview.
- **Layout:**
  1. Header: avatar, name, role ("Security Officer · Unit S-3"), bell.
  2. **Duty status card:** large toggle (On Duty / Break / Off Duty) with a colored dot, shift time and live GPS indicator.
  3. **Stat row (3 cards):** Active workload, Responded today, Avg response time.
  4. **Current assignment card** (if any): severity-colored left border, category, location, ETA, "Open" CTA. Otherwise an "Awaiting assignments" state with a radar-style animation.
  5. **Nearby incidents / queue:** list of 2–3 recent items (read-only).
  6. **Recent activity:** last 3 responses.
- **States:** Off duty (muted, assignments disabled with a banner), on duty idle, on duty with assignment.

### 6.7 Incoming Assignment (high visual priority)
- **Purpose:** Urgent accept/decline decision.
- **Layout:** Full-screen dark-navy overlay with a red severity band at the top ("CRITICAL"). Contains: category icon and title, location, distance and ETA ("1.2 km · 4 min"), people affected, photo preview, "Why you?" chips (Medical skill match, Nearest, Low workload), a circular countdown (e.g. 30 s) around the Accept button, and "Decline" as a secondary button.
- **Actions:** Accept → Active Incident; Decline → reason bottom sheet (Busy, Too far, Unavailable) → Dashboard.
- **States:** Countdown expiry → "Escalated to next responder" toast.

### 6.8 Active Incident & Navigation
- **Layout:** Full-screen map with the route polyline and responder/incident markers. Top: floating card with the incident title, severity badge, and ETA/distance. Bottom sheet:
  - Status action button (large, contextual): "Start Navigation" → "Mark Arrived" → "Mark Resolved"
  - Incident details (category, photo, description, reporter contact)
  - Timeline (collapsed, expandable)
  - Secondary actions: **Request Backup** (outlined, amber), Call reporter
- **Request Backup sheet:** type selector (Medical / Security / Fire), a note field, "Send Request".
- **Resolve flow:** Dialog asking for outcome (Resolved / False alarm / Transferred) and an optional note, then a success state.

### 6.9 Response History
- List with date filter chips and cards (incident type, duration, outcome badge). A summary row on top shows total responses and average time.

### 6.10 Command Center (high visual priority)
- **Layout (desktop/tablet):** Left rail navigation. Main area:
  1. **Top bar:** title, live clock, search, filters (Severity, Status, Category), alert bell, admin avatar.
  2. **KPI row (5 stat cards):** Active incidents, Critical, Unassigned/Escalated, Available responders, Avg response time.
  3. **Escalation banner** (when applicable): amber, with "Assign now".
  4. **Split view:** left 60% map with color-coded incident pins and responder pins; right 40% live incident feed (cards sorted by severity, with status badges and ETA).
  5. Bottom/side: small chart (incidents by category, bar) and a recent activity list.
- **Phone fallback:** KPIs scroll horizontally, a Map/List segmented toggle, and a bottom nav.
- **Actions:** Select a pin or card → Incident Detail panel.

### 6.11 Incidents list + Incident Detail
- **List:** Data table (desktop) or cards (mobile) with ID, category, severity, status, responder, time. Filter bar above.
- **Detail panel (right drawer):** header with ID and severity score ("Severity 8.4 / 10") and breakdown bars (category, keywords, people, time, location risk); photo; location mini-map; **assigned responder card**; **Ranked candidates list** (top 3 responders with score, ETA, skill match, workload); **Override assign** button; full **Timeline**.
- **Override sheet:** radio list of responders, a reason field, and a confirmation dialog.

### 6.12 Responders roster
- Grid/list of responder cards: avatar, type, skills chips, duty status dot, current workload bar (e.g. 1/3), and last-seen location. Filters: type, status. Tapping opens a small detail sheet.

### 6.13 Statistics
- Date-range chips; 4 charts (incidents over time line, by category bar, response time trend, resolution outcomes donut); a small table of top locations. Use simple chart styles to keep this implementable.

### 6.14 Notifications (shared)
- Grouped list (Today / Earlier), each item with a colored icon, title, message, and time. Types: assignment, escalation, status change. Unread items have a blue dot. Empty state included.

### 6.15 Profile/Settings (shared)
- Avatar header with role badge, info rows, and toggles (notifications, location sharing), plus Logout. Responder variant adds skills and unit.

---

## 7. Professional UI/UX Design System

**Design direction:** "Calm authority." A dark navy and white base conveys trust and control; red is reserved strictly for emergencies and severity so it keeps its meaning. Crisp data presentation, rounded but not playful.

### Color system

| Token | Hex | Use |
|---|---|---|
| Primary | `#0B2545` (navy) | App bars, headers, primary buttons, command center rail |
| Primary Accent | `#13508F` | Links, active nav, selected chips |
| Secondary | `#E63946` (alert red) | SOS and critical only |
| Background | `#F4F6FA` | Screen background |
| Surface | `#FFFFFF` | Cards, sheets |
| Surface Dark | `#0F172A` | Incoming assignment, command center dark panels |
| Text Primary | `#101828` | Headings, body |
| Text Secondary | `#667085` | Captions, metadata |
| Border | `#E4E7EC` | Dividers, outlines |
| Success | `#12B76A` | Resolved, on duty, available |
| Warning | `#F79009` | Escalated, backup, medium severity |
| Error | `#D92D20` | Failures, critical |
| Info | `#2E90FA` | Assigned, informational |

**Severity scale:** Low `#12B76A`, Medium `#F79009`, High `#F04438`, Critical `#B42318` (with a filled badge). Always pair color with an icon or label, never color alone.

### Typography
Use **Inter** (or Plus Jakarta Sans) via `google_fonts`.
- Display/Screen title: 24–28 / Bold
- Heading (section): 18–20 / SemiBold
- Subheading: 16 / SemiBold
- Body: 14–15 / Regular, line height 1.45
- Label/Caption: 12 / Medium (uppercase tracking only for small badges)
- Button: 15 / SemiBold
- Numeric KPIs: 28 / Bold with tabular figures

### Components
- **Cards:** white, 16 px radius, 1 px border `#E4E7EC`, very subtle shadow (blur 12, 4% opacity), 16 px padding. Severity cards add a 4 px colored left edge.
- **Buttons:** Primary = navy filled, 52 px high, 14 px radius. SOS/Critical = red filled. Secondary = outlined navy. Tertiary = text. Pressed state darkens 8%; disabled at 40% opacity; loading shows an inline spinner.
- **Text fields:** filled `#F9FAFB`, 12 px radius, 1 px border, blue focus ring, floating label, helper/error text below.
- **Navigation:** Bottom `NavigationBar` (Material 3) with a 4-item pill indicator on mobile; side `NavigationRail` (navy, icon + label) on wide screens.
- **Bottom sheets:** 24 px top radius, drag handle, snap points; used for decline reasons, backup, and override.
- **Dialogs:** 20 px radius, icon header, clear primary/secondary actions; destructive actions in red.
- **Status badges:** pill, tinted background (12% of status color), colored text and a small dot. Statuses: Reported, Assigned, En Route, Arrived, Resolved, Escalated.
- **Alerts/banners:** full-width rounded container with a tinted background, leading icon, message, and an optional action link. Types: info, warning, error, success.
- **Progress indicators:** linear stepper for incident status; circular countdown for assignment; shimmer skeletons for loading.
- **Lists:** 12 px vertical padding, leading icon container (40 px, tinted), trailing chevron or badge, 1 px dividers inset.
- **Dashboard statistics:** card with a small tinted icon, big number, label, and optional trend chip (▲ 12%).
- **Motion:** 200–300 ms ease-out transitions; the only repeating animations are the SOS pulse and the "searching" shimmer.

### Dashboard design summary
- **Student:** Hero SOS + active-incident banner; the structure favors one decision.
- **Responder:** duty control first, then workload stats, then the current assignment, which is the most prominent card.
- **Admin:** KPI strip, then map/feed split (the "control room" look), then charts. Dark rail with a light content area gives a commercial dashboard feel.

---

## 8. Reusable Components

Build these once in `widgets/`:
- `AppScaffold` (adaptive: bottom nav on mobile, rail on wide screens)
- `RgAppBar` (title, optional back/close, notification action)
- `PrimaryButton`, `SosButton` (pulse + hold progress), `OutlineActionButton`
- `RgTextField`
- `StatusBadge`, `SeverityBadge`
- `StatCard`
- `IncidentCard` (used in the student, responder, and admin lists)
- `ResponderCard`
- `CategoryTile` and `CategoryChip`
- `IncidentStepper` (horizontal status)
- `TimelineView` (vertical, event icon + time)
- `MapPanel` (wrapper around a map widget with the pins/route overlay)
- `InfoBanner` (alert types)
- `RgBottomSheet` helper, `ConfirmDialog`
- `EmptyState`, `LoadingSkeleton`, `ErrorState`
- `DutyToggleCard`
- `CountdownRing`
- `SectionHeader` (title + "View all")

---

## 9. Flutter Folder Structure

```
lib/
├─ main.dart
├─ app/
│  ├─ app.dart                // MaterialApp, theme, router
│  └─ router.dart             // go_router with role-based routes
├─ core/
│  ├─ theme/                  // colors.dart, typography.dart, app_theme.dart
│  ├─ constants/              // spacing, radii, strings, icons map
│  └─ utils/                  // formatters (time, distance)
├─ data/
│  ├─ models/                 // incident.dart, responder.dart, user.dart, event.dart
│  └─ mock/                   // mock_incidents.dart, mock_responders.dart, mock_users.dart
├─ features/
│  ├─ auth/                   // login_screen.dart
│  ├─ student/                // home, report, tracking, my_reports
│  ├─ responder/              // dashboard, incoming_assignment, active_incident, history
│  ├─ admin/                  // command_center, incidents, incident_detail, responders, statistics
│  ├─ notifications/          // notifications_screen.dart
│  └─ profile/                // profile_screen.dart
└─ widgets/                   // shared reusable components (section 8)
```

**Suggested packages (UI-only stage):** `go_router`, `google_fonts`, `flutter_map` (or `google_maps_flutter`), `fl_chart`, `shimmer`, `image_picker` (for the photo UI), `provider` (or just `ValueNotifier`) for simple mock state. Add `lucide_icons` or `phosphor_flutter` for a more polished icon set than the default Material icons.

---

## 10. Mock Data Requirements

- **Users:** 1 student (Aisha Rahman), 2 responders (a medic and a security officer), 1 admin, with roles for the demo selector.
- **Incidents (8–10):** mix of categories and severities; statuses spanning Reported → Resolved; one escalated; one critical active; each with ID, coordinates, address, photo asset, description, people affected, severity score and breakdown, timestamps.
- **Responders (6–8):** type (Medical/Security/Fire), skills, duty status, workload (current/max), mock coordinates, rating-free stats (responses today, average time).
- **Candidate ranking:** hard-coded top 3 per incident with score, ETA, and match reasons.
- **Timeline events:** per incident (Reported, Severity scored, Assigned, Accepted, En Route, Arrived, Resolved) with timestamps.
- **Notifications:** 6–8 mixed items.
- **Statistics:** static series for charts (incidents per day, by category, response time trend).
- **Map:** static campus coordinates around one fixed center, with a precomputed polyline for the demo route and a timer-driven marker movement to simulate live tracking.
- **Simulated live updates:** a single mock "event ticker" (a `Timer` advancing an incident's status every few seconds) to fake real-time.

---

## 11. Implementation Phases

| Phase | Screens | Components | Expected result | Priority |
|---|---|---|---|---|
| **1. Setup + design system** | none | Theme, colors, typography, spacing, `PrimaryButton`, `RgTextField`, `StatusBadge`, `SeverityBadge`, `StatCard`, `RgAppBar` | App skeleton with a polished theme and component showcase | Highest |
| **2. Authentication + routing** | Login | Role chips for demo, router with role redirect, adaptive scaffold | Branded login that lands on the right role shell | Highest |
| **3. Main dashboards** | Student Home, Responder Dashboard, Command Center | `SosButton`, `CategoryTile`, `DutyToggleCard`, `IncidentCard`, `InfoBanner` | The three first-impression screens, fully styled | Highest |
| **4. Core feature screens** | Report Emergency, Incoming Assignment, Active Incident & Navigation | `CountdownRing`, map panel, bottom sheets (decline, backup), confirm dialogs | Main flows are clickable end to end | High |
| **5. Details and tracking** | Incident Tracking, Incident Detail + override, Responders roster | `IncidentStepper`, `TimelineView`, `ResponderCard` | Real-time feel, timeline, ranked candidates | High |
| **6. Remaining screens** | My Reports, Response History, Notifications, Statistics, Profile | List patterns, `fl_chart` charts, `EmptyState` | Complete role coverage | Medium |
| **7. Mock data + simulation** | All | Models, mock repositories, status ticker, moving marker | Demo runs from fake data with simulated live updates | High |
| **8. Polish + testing** | All | Loading/empty/error states, transitions, responsive checks, spacing audit | Consistent, bug-free demo build | High |

*Note:* Do Phase 7's data models early (alongside Phase 3) so the dashboards render realistic content from the start.

---

## 12. Must Have / Should Have / Optional

### MUST HAVE
- Login with role-based redirect
- Student Home with SOS and categories
- Report Emergency (category, photo UI, location card, description)
- Incident Tracking with status stepper and timeline
- Responder Dashboard with duty toggle
- Incoming Assignment with accept/decline
- Active Incident screen with map, ETA, and status update buttons
- Command Center dashboard (KPIs, map, incident feed)
- Incident Detail with timeline
- Consistent design system and severity/status badges

### SHOULD HAVE
- Ranked candidates and severity breakdown in Incident Detail
- Manual override sheet
- Request Backup sheet
- Notifications screen
- Escalation banner and "reassigning" state
- My Reports and Response History
- Responders roster
- Simulated live status updates and a moving responder marker
- Statistics charts
- Skeleton/empty/error states

### OPTIONAL
- Dark mode
- Onboarding screens
- Hold-to-send haptics and sound
- Map clustering and heatmap
- Profile skill editing
- Localization
- Splash animation and Lottie illustrations

---

## 13. Final Contest Demo Flow (about 5 minutes)

1. **Open on Login (15 s):** Show the branded screen and sign in as **Student** via SSO. Mention role-based access.
2. **Student Home (20 s):** Point out the SOS hero, category grid, and the "GPS active" status.
3. **Report (40 s):** Choose "Medical," confirm the auto-detected location, set people affected to "2–5," attach a photo, and send.
4. **Tracking (30 s):** Show the "Finding the nearest responder…" state. The status moves to **Assigned** and the responder card and ETA appear on the map.
5. **Switch to Responder (45 s):** Dashboard shows On Duty; the **Incoming Assignment** screen appears with the countdown and the "Why you?" chips. Accept.
6. **Active Incident (45 s):** Show the map route and ETA, press **Start Navigation**, then **Mark Arrived**. Briefly show **Request Backup**.
7. **Back to Student (20 s):** Tracking has progressed live to **Arrived**, and the timeline has grown.
8. **Command Center (60 s):** Switch to the admin view. Show the KPI row, map pins, and live feed. Open the incident: severity breakdown, ranked candidates, **manual override**, and the full timeline. Point out an **escalated** incident example from the mock data.
9. **Resolve (20 s):** The responder resolves the incident; the student sees the green resolved summary; the admin timeline shows the complete chronological record.
10. **Close (15 s):** Show the Notifications and Statistics screens and summarize: quick reporting, smart assignment, live tracking, and an auditable record.

**Tip:** Run the mock-event ticker on a short interval (3–5 s per status) so the demo reads as real-time without waiting.
