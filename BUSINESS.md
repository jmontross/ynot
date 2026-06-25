# YNOT Fitness — Custom Gyms

> Business brief assembled from the brand/social images in this folder. This is
> the seed document for a one-page landing site (Sinatra) that will grow into an
> app to manage YNOT Fitness's business operations.

## What the business is

YNOT Fitness designs, builds, and installs **custom gyms**. The work shown in
the photos is a full build-out service — taking an empty room, garage, or
commercial space and turning it into a finished, ready-to-train gym:

The service is sold as a four-step, end-to-end process:

1. **Design** — plan the space: layout, flooring, walls, mirrors, equipment.
2. **Rendering** — a visual rendering of the finished gym before any build.
3. **Purchasing** — source equipment and materials on the customer's behalf.
4. **Installation** — flooring, walls, mirrors, and equipment installed and
   ready to train.

Underlying scope delivered through those steps: rubber/gym flooring, wall
treatments and finishing, mirror installation, and equipment supply & setup
(power racks, squat racks, treadmills, benches) — full before → after build-outs.

This is **not** a membership/club gym. The customer is someone who wants a gym
*built for them* — home gyms, garage gyms, and light-commercial spaces.

### Mission (their words)
> "Help you create the best gym to fit your fitness goals."

## Brand

- **Name:** YNOT Fitness
- **Tagline:** Custom Gyms
- **Logo:** Boxed "YNOT" wordmark with "FITNESS" beneath and a "Custom Gyms"
  banner. Monochrome (black on white); purple accent appears in one social tile.
- **Voice:** Practical, motivational, build-focused.

## Contact / presence

| Channel  | Value |
|----------|-------|
| Phone    | +1 214-440-8012 |
| Email    | ynot9097@gmail.com |
| Facebook | YNOT Fitness Custom Gyms |
| Category | Gym / Physical Fitness Center |
| Region   | Dallas–Fort Worth, TX (214 area code) |

## Landing page — v1 scope (this milestone)

A single page that loads fast on mobile (his audience finds him on Facebook) and
does three things:

1. **Says what he does** — "We build custom gyms." Hero + the mission line.
2. **Shows proof** — a photo gallery of completed build-outs.
3. **Makes contact one tap away** — call, email, and a short "Request a quote"
   lead form.

### Sections
- Hero (logo, tagline, primary CTA: *Request a quote* / *Call now*)
- Services (Flooring · Walls & Mirrors · Equipment · Full Build-Out)
- Gallery (the build photos)
- About / mission
- Contact + lead form

## Where this goes next (operations app)

The landing page is built as a real Sinatra app so it can grow into the back
office. Likely modules, in rough priority order:

1. **Leads / CRM** — capture quote requests, track status (new → quoted → won/lost).
2. **Projects** — each gym build as a job: client, scope, timeline, photos.
3. **Quotes & invoices** — line items for flooring, equipment, labor.
4. **Scheduling** — installs and site visits.
5. **Gallery/portfolio CMS** — manage the public photos from inside the app.

## Hosting

Target: **AWS**. The app is structured (Rack/Sinatra, `config.ru`) to run
behind any standard Ruby host — Elastic Beanstalk, an EC2 instance with Puma +
Nginx, or App Runner. Static assets in `public/`. No DB yet (the lead form can
start by emailing/logging); a managed Postgres (RDS) slots in when the
operations modules land.
