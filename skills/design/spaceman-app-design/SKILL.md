---
name: spaceman-app-design
description: House method for designing iOS app screens and components that feel tactile, native and rhythmic. Covers choosing a shape direction (squircle or stadium), the shape lock and radius scale, concentric corners for nested content, the 4pt rhythm, tactile raised surfaces in light and dark, type and colour roles (no fixed colours), native fidelity and navigation intent, named components, full state cycles, the visual bar, and a measured audit before shipping. Use when designing or reviewing any mobile app screen, component, design canvas or design system, for any product. Triggers on "design a screen", "design this app", "make a component", "audit the corners", "fix the rhythm", "squircle or capsule", "spaceman".
---

# Spaceman app design

A method for app UI that feels physical, native and calm. It is product-neutral: it sets roles, ratios and rules, never colour values. Each product brings its own palette, typeface and brand accent.

Pairs with `tactile-design` (surfaces and controls) and `appllama-app-design-skill` (native fidelity and navigation). This skill is the house layer on top of both.

## Scope

- In: screens, components, tokens, shape, spacing, type roles, colour roles, states, navigation intent, motion intent.
- Out: build tooling, backend, simulator loop, performance. Use the companion skills for those.

## 1. Choose the shape direction first

Before any screen, pick one direction. It changes every radius.

| Direction | Corner | Feels | Fits |
|---|---|---|---|
| **S: Squircle** | Corner smoothing (`corner-shape: squircle`, iOS continuous curve) | Calm, native, precise | Utility, finance, health, tools, pro apps |
| **C: Stadium / capsule** | Plain round (`corner-shape: round`), pills where possible | Soft, friendly, playful | Consumer, social, kids, lifestyle |

- Judge the product: audience, tone, brand. State your pick and the reason in one line.
- If the fit is not clear, ask the user one question and show both options side by side.
- Optional: produce S and C copies of key boards, light and dark, so the user can compare.
- Once chosen, the direction is a rule. Apply it to every board in the same change.
- System chrome (status bar, tab bar, native switch, keyboard) is exempt. It stays as iOS draws it.

## 2. Shape lock

One radius scale on the 4pt grid. Write it as a table in the product's rules doc and never use a radius outside it without a new decision.

Default scale (adjust values per product, keep the roles):

| Role | Shape | Radius |
|---|---|---|
| Buttons, chips, pills, badges | Full round | full |
| Row (64 high) | Capsule-ended | half the height (32) |
| Icon frame (40) | Full squircle / circle | 20 |
| Card, tile | Scale value | 48 (or 24–32 for dense apps) |
| Sheet, top corners | Same as cards | 48 |
| Text field inside a 64 row (48 high) | Concentric | 24 |
| Text field on its own | Scale value | 32 |
| Search field | Full round | full |
| Segmented track / thumb | Half the height each | e.g. 22 / 18 |

- Do not mix squircle and stadium inside one stack.
- Siblings share one radius. An unmatched sibling is a bug.

## 3. Concentric framing (when content is nested)

Use this only where one shape sits inside another with padding around it.

- **Inner radius = outer radius − padding.**
- If the inner result is under 8, square the inner shape or change the padding. Never let the inner corner look rounder than the outer.
- A framed child has the same padding on every side, so the curves stay parallel.
- Check each nested pair: card → row, card → field, row → tint, sheet → card, track → thumb.
- A child that does not touch the frame's corners does not need to be concentric.

## 4. Rhythm

- 4pt grid for all spacing, sizes and radii. No odd values.
- Standard heights: 44 (targets, search, segmented), 48 (title bands, fields in rows), 64 (rows).
- Gutters: 20 on the phone edge, 16 inside cards.
- Icon-led rows: icon side 4 tighter than the text side (e.g. `8 16 8 12`).
- Spacing: 4–8 inside a control, 12–16 between items, 24–32 between sections.
- Use `gap`. Do not stack margins.
- Match the neighbour: same height, padding, radius and text size across siblings.

## 5. Tactile surfaces

Hierarchy and pressability come from light and edge, not decoration.

- **Light:** raised = top surface + fine ring + crisp 1px drop. No big soft blur.
- **Dark:** raised = one or two steps lighter than the parent + solid 0.5px outline + black drop. Never a lit top edge, never a glow.
- **Borrow from the parent:** fill, edge and drop come from the surface beneath.
- Fields are wells (sunk), not outlined boxes.
- Buttons are raised, never gradient. Press = `scale(.97)`.
- One primary per screen. It uses the product's accent (opted in) or the strong ink.
- Secondary = raised top surface. Destructive is never the primary.
- Field error = 1px danger ring + message under the field.
- Sizes, padding, radius and border width never change between light and dark.

## 6. Type and colour roles (no fixed values)

- Two weights only: one for display and labels, one for body. Bold is not a hierarchy tool.
- Hierarchy = a size step plus an ink step (strong, secondary, faint).
- Use the platform ramp. One display size per screen. Tabular figures for anything that counts.
- One accent, locked across every screen. One grey family (warm or cool, not both).
- Hue carries meaning only: status (success, danger, warning, info) or identity (a category chip as a tint fill with dark text in its own hue).
- Identity chips: coloured squircle (or circle, per direction) icon frames on a muted base.
- Write real product copy. Use the product's own words for units. Never echo prompt wording. Sentence case, no em dashes, "…" not three dots.

## 7. Native fidelity and navigation

- SF Symbols only. No emoji in chrome. One icon family.
- Native controls: switch, segmented control, sheets with detents, context menus, pickers.
- The navigator owns the title and large-title collapse.
- Respect safe areas, the Dynamic Island and the home indicator.
- Navigation intent, stated per screen:
  - push = go deeper, user returns;
  - replace = move on, no return;
  - modal = a self-contained task with Cancel/Done;
  - sheet = a short interruption, drag to dismiss.
- One-way doors (onboarding end, waitlist, sign-in, purchase) leave the stack. Back never re-enters.
- One label per intent across the app.
- Touch targets 44pt. Body text 15 floor, fields 16.

## 8. Components

- Name every component (PascalCase, e.g. `TextField`, `InfoCard`, `SuccessBadge`, `AddSheet`).
- Keep a component register in the project: name, use, size, radius, states, light/dark notes. Update it in the same change.
- Reuse before inventing. A new component needs a reason.
- Tag components in the markup (`data-component="Name"`) so audits can find them.

## 9. Full state cycle

Every screen ships with:

- loaded, empty, loading, error;
- worst-case data (long names, huge numbers, missing values);
- skeletons with the same shape and size as the final layout;
- no fake data, no layout jump when data arrives.

## 10. Visual bar

- Flat, template screens fail. Give the product character: a brand mark, real photography or illustration in one style, depth from tactile layers.
- Character comes from composition and imagery, not gradients, glows or glass on every card.
- One hero moment per screen. Everything else is quiet.

## 11. Workflow

1. Read the product's rules doc and component register, if they exist. If not, create them.
2. Choose the shape direction (section 1). Record it.
3. Write the shape lock table (section 2) for this product.
4. Study references for the screen type (Mobbin or Appllama), link every reference.
5. Design light first, then dark on purpose.
6. Name components as you build them.
7. Run the audit (section 12) before calling anything done.
8. Record every decision in a decisions doc with the date and reason.

When the user is still deciding, change nothing until they ask.

## 12. Audit before shipping

Measure the values in code. Do not judge by eye.

- [ ] Every radius is in the shape lock table.
- [ ] Every nested pair is concentric, or the child does not touch the corners.
- [ ] Every spacing and size is on the 4pt grid.
- [ ] Siblings match in height, padding, radius and text.
- [ ] Light and dark checked at zoom; dark has no lit edge or glow.
- [ ] Slop count: 1 accent, 0 gradients without brand reason, 0 emoji in chrome, 0 duplicate labels for one intent, 2 weights.
- [ ] Every screen has its state cycle.
- [ ] Every component is named and in the register.
- [ ] Navigation intent stated for every screen.

A failed count is a fix, applied to every instance, not a judgment call.
