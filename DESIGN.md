---
name: LifeOS
colors:
  surface: '#f7f9ff'
  surface-dim: '#d7dae0'
  surface-bright: '#f7f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f1f4fa'
  surface-container: '#ebeef4'
  surface-container-high: '#e5e8ee'
  surface-container-highest: '#dfe3e8'
  on-surface: '#181c20'
  on-surface-variant: '#414754'
  inverse-surface: '#2d3135'
  inverse-on-surface: '#eef1f7'
  outline: '#727785'
  outline-variant: '#c1c6d6'
  surface-tint: '#005bc0'
  primary: '#005bbf'
  on-primary: '#ffffff'
  primary-container: '#1a73e8'
  on-primary-container: '#ffffff'
  inverse-primary: '#adc7ff'
  secondary: '#006e2c'
  on-secondary: '#ffffff'
  secondary-container: '#86f898'
  on-secondary-container: '#00722f'
  tertiary: '#795900'
  on-tertiary: '#ffffff'
  tertiary-container: '#987000'
  on-tertiary-container: '#ffffff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d8e2ff'
  primary-fixed-dim: '#adc7ff'
  on-primary-fixed: '#001a41'
  on-primary-fixed-variant: '#004493'
  secondary-fixed: '#89fa9b'
  secondary-fixed-dim: '#6ddd81'
  on-secondary-fixed: '#002108'
  on-secondary-fixed-variant: '#005320'
  tertiary-fixed: '#ffdfa0'
  tertiary-fixed-dim: '#fbbc05'
  on-tertiary-fixed: '#261a00'
  on-tertiary-fixed-variant: '#5c4300'
  background: '#f7f9ff'
  on-background: '#181c20'
  surface-variant: '#dfe3e8'
typography:
  headline-xl:
    fontFamily: Inter
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.03em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 8px
  sm: 12px
  md: 16px
  lg: 24px
  xl: 32px
  grid-margin: 24px
  grid-gutter: 16px
---

## Brand & Style

The design system is built on the philosophy of "Structured Serenity." It functions as a high-end digital butler: invisible when not needed, yet authoritative and precise when called upon. The system balances the rigorous organization required for finance and health with the approachable warmth of a personal assistant.

The aesthetic leans into **Corporate Modernism** with a **Tactile** edge. It utilizes a modular, card-based architecture to decompose complex life data into digestible, actionable units. High-quality whitespace and a restricted color application ensure that the user feels empowered rather than overwhelmed by their own data.

## Colors

The palette is anchored by **Trust Blue**, used strategically for primary actions and navigation to establish a foundation of stability. **Success Green** is reserved strictly for positive growth indicators—financial gains, health goal completions, and "system-go" states. **Action Orange** serves as a high-contrast utility color for reminders, pending tasks, and time-sensitive alerts.

The background uses a soft "Off-White" to prevent screen glare and reduce eye strain during long planning sessions. Surface colors are pure white to create clear separation from the background.

## Typography

This design system utilizes **Inter** exclusively to ensure maximum legibility across dense data sets. The typographic scale is highly hierarchical, using weight and tight letter-spacing in headlines to create a sense of importance and "news-like" authority. 

Body text maintains a generous line height (1.5x) to ensure long-form diary entries or financial statements are easy to scan. Label styles use increased tracking and semi-bold weights to remain distinct even at small sizes.

## Layout & Spacing

The layout follows a **Fluid Grid** model. On desktop, a 12-column grid is used, while mobile scales down to a single column with consistent 24px side margins. 

The spacing system is based on a 4px baseline, but emphasizes the "lg" (24px) unit for internal card padding to maintain an airy, premium feel. Content is grouped into logical sections using "xl" (32px) vertical spacing to clearly define the transitions between different life categories (e.g., Finance vs. Wellness).

## Elevation & Depth

Hierarchy is established through **Ambient Shadows** and **Tonal Layering**. 

1.  **Level 0 (Background):** The soft neutral base.
2.  **Level 1 (Cards):** Pure white surfaces with a subtle 4px blur, 5% opacity black shadow. This is the standard state for most content.
3.  **Level 2 (Interactive/Active):** An 8px blur, 8% opacity shadow, used when a card is being interacted with or contains urgent "Action Orange" content.
4.  **Level 3 (Modals/Overlays):** A 16px blur shadow with a soft backdrop dimming to focus the user on a specific task (like adding an expense).

## Shapes

The shape language is defined by the **Rounded** (0.5rem / 8px) base, but for the primary card containers of this design system, we utilize the `rounded-xl` (1.5rem / 24px) token to evoke a friendlier, modern mobile app feel. 

Buttons use a `rounded-lg` (16px) setting to appear approachable and tactile, signaling to the user that these elements are meant to be touched.

## Components

### Buttons
Primary buttons use the Trust Blue background with white text. Secondary buttons use a subtle light-blue tint (10% opacity) with Trust Blue text. All buttons have a minimum height of 48px to ensure accessibility.

### Cards
Cards are the primary container. Every card must have 24px internal padding. Title areas within cards should be separated by a thin 1px border (#E8EAED) or simply by the typography hierarchy.

### Input Fields
Inputs use a "Level 0" background (the soft neutral) to look recessed, creating a "fill-in-the-blank" affordance. Upon focus, the border transitions to a 2px Trust Blue stroke.

### Chips & Tags
Used for categorization (e.g., "Health," "Work"). These are pill-shaped and use a low-saturation version of the category color to ensure text remains the focal point.

### Lists
List items use a subtle divider between entries. For financial or health data, the right-hand side of the list item is reserved for "Value Strings" (e.g., "$120.00" or "10k Steps") in a semi-bold weight.