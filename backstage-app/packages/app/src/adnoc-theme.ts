/**
 * ADNOC MUI v4 Theme
 *
 * Drop this file into your React app and import it wherever you call
 * `<ThemeProvider theme={adnocTheme}>`.
 *
 * PREREQUISITES
 * ─────────────
 * 1. Copy the font files from the Angular project's `public/fonts/` directory
 *    into your React app's `public/fonts/` (or wherever your static assets live).
 *    Required files:
 *      ADNOCSANS_LT.TTF   (weight 300)
 *      ADNOCSANS_RG.TTF   (weight 400)
 *      ADNOCSANS_MD.TTF   (weight 500)
 *      ADNOCSANS.TTF      (weight 700)
 *
 * 2. Register the @font-face rules in your global CSS / index.css:
 *
 *    @font-face {
 *      font-family: 'ADNOC Sans';
 *      src: url('/fonts/ADNOCSANS_LT.TTF') format('truetype');
 *      font-weight: 300; font-style: normal; font-display: swap;
 *    }
 *    @font-face {
 *      font-family: 'ADNOC Sans';
 *      src: url('/fonts/ADNOCSANS_RG.TTF') format('truetype');
 *      font-weight: 400; font-style: normal; font-display: swap;
 *    }
 *    @font-face {
 *      font-family: 'ADNOC Sans';
 *      src: url('/fonts/ADNOCSANS_MD.TTF') format('truetype');
 *      font-weight: 500; font-style: normal; font-display: swap;
 *    }
 *    @font-face {
 *      font-family: 'ADNOC Sans';
 *      src: url('/fonts/ADNOCSANS.TTF') format('truetype');
 *      font-weight: 700; font-style: normal; font-display: swap;
 *    }
 *
 * USAGE (plain MUI v4)
 * ────────────────────
 *    import { ThemeProvider } from '@material-ui/core/styles';
 *    import { adnocTheme } from './adnoc-theme';
 *
 *    <ThemeProvider theme={adnocTheme}>
 *      <App />
 *    </ThemeProvider>
 *
 * USAGE (Backstage — @backstage/theme ^0.7.1)
 * ────────────────────────────────────────────
 *    import { ThemeProvider } from '@material-ui/core/styles';
 *    import { CssBaseline } from '@material-ui/core';
 *    import { UnifiedThemeProvider, createUnifiedTheme } from '@backstage/theme';
 *    import { adnocThemeOptions } from './adnoc-theme';
 *
 *    const adnocBackstageTheme = createUnifiedTheme(adnocThemeOptions);
 *
 *    // In your App.tsx AppTheme configuration:
 *    const adnocAppTheme: AppTheme = {
 *      id: 'adnoc-theme',
 *      title: 'ADNOC Theme',
 *      variant: 'light',
 *      Provider: ({ children }) => (
 *        <UnifiedThemeProvider theme={adnocBackstageTheme} noCssBaseline>
 *          <CssBaseline />
 *          {children}
 *        </UnifiedThemeProvider>
 *      ),
 *    };
 */

import { createTheme, ThemeOptions } from '@material-ui/core/styles';

// ─── Color tokens ────────────────────────────────────────────────────────────

const colors = {
  // Primary
  primaryMain: '#1859A9',       // adnoc-flash-blue / primary-color
  primaryDark: '#1E3A6B',       // adnoc-navy
  primaryLight: '#0075C9',      // adnoc-cool-blue / primary-container

  // Backgrounds / surfaces
  background: '#f5f7f9',        // surface-color
  paper: '#ffffff',             // surface-container-lowest

  // Text
  textPrimary: '#1b1b1b',       // on-surface
  textSecondary: '#4D5156',     // on-surface-variant / adnoc-steel-gray

  // Semantic
  success: '#2e7d32',
  error: '#d32f2f',
  warning: '#ed6c02',
  info: '#0288d1',

  // Neutral grays
  coolGray: '#9D9FA0',          // adnoc-cool-gray
  lightGray: '#dddfe1',         // adnoc-light-gray
  activeBg: '#E5F1FA',          // adnoc-active-bg

  // Borders
  borderSubtle: 'rgba(24, 89, 169, 0.10)',
  borderNeutral: 'rgba(0, 0, 0, 0.04)',
} as const;

// ─── Shadow tokens ───────────────────────────────────────────────────────────

const shadows = {
  xs:        '0 2px 10px rgba(0, 0, 0, 0.03)',
  sm:        '0 4px 12px rgba(0, 0, 0, 0.05)',
  md:        '0 10px 30px rgba(0, 0, 0, 0.05)',
  overlay:   '0 18px 50px rgba(24, 89, 169, 0.12), 0 6px 18px rgba(0, 0, 0, 0.08)',
  primaryXs: '0 4px 8px rgba(24, 89, 169, 0.22)',
  primarySm: '0 8px 20px rgba(24, 89, 169, 0.22)',
  primaryMd: '0 16px 32px rgba(24, 89, 169, 0.18)',
  primaryLg: '0 18px 30px rgba(24, 89, 169, 0.30)',
  float:     '0 6px 20px rgba(0, 0, 0, 0.18)',
  text:      '0 10px 24px rgba(24, 89, 169, 0.20)',
} as const;

// ─── Font tokens ─────────────────────────────────────────────────────────────

const fontFamily = 'Arial, Helvetica, sans-serif';

const fontSizes = {
  xs:   '0.75rem',    // 12px
  sm:   '0.875rem',   // 14px
  base: '1rem',       // 16px
  lg:   '1.125rem',   // 18px
  xl:   '1.25rem',    // 20px
  '2xl': '1.5rem',    // 24px
  '3xl': '1.875rem',  // 30px
  '4xl': '2.25rem',   // 36px
} as const;

// ─── MUI v4 ThemeOptions ──────────────────────────────────────────────────────

export const adnocThemeOptions: ThemeOptions = {
  palette: {
    type: 'light',
    primary: {
      main:  colors.primaryMain,
      dark:  colors.primaryDark,
      light: colors.primaryLight,
      contrastText: '#ffffff',
    },
    secondary: {
      main:  colors.primaryLight,
      dark:  colors.primaryMain,
      light: colors.activeBg,
      contrastText: '#ffffff',
    },
    error: {
      main: colors.error,
    },
    warning: {
      main: colors.warning,
    },
    info: {
      main: colors.info,
    },
    success: {
      main: colors.success,
    },
    text: {
      primary:   colors.textPrimary,
      secondary: colors.textSecondary,
      disabled:  colors.coolGray,
    },
    background: {
      default: colors.background,
      paper:   colors.paper,
    },
    divider: colors.lightGray,
  },

  typography: {
    fontFamily,
    fontSize: 16,         // maps to $font-size-base (1rem)

    h1: { fontFamily, fontWeight: 700, fontSize: fontSizes['4xl'], lineHeight: 1.25 },
    h2: { fontFamily, fontWeight: 700, fontSize: fontSizes['3xl'], lineHeight: 1.25 },
    h3: { fontFamily, fontWeight: 600, fontSize: fontSizes['2xl'], lineHeight: 1.25 },
    h4: { fontFamily, fontWeight: 600, fontSize: fontSizes.xl,    lineHeight: 1.25 },
    h5: { fontFamily, fontWeight: 500, fontSize: fontSizes.lg,    lineHeight: 1.5  },
    h6: { fontFamily, fontWeight: 500, fontSize: fontSizes.base,  lineHeight: 1.5  },

    subtitle1: { fontFamily, fontWeight: 500, fontSize: fontSizes.base, lineHeight: 1.5 },
    subtitle2: { fontFamily, fontWeight: 500, fontSize: fontSizes.sm,   lineHeight: 1.5 },

    body1: { fontFamily, fontWeight: 400, fontSize: fontSizes.base, lineHeight: 1.5 },
    body2: { fontFamily, fontWeight: 400, fontSize: fontSizes.sm,   lineHeight: 1.5 },

    button: { fontFamily, fontWeight: 500, fontSize: fontSizes.base, textTransform: 'none' },
    caption: { fontFamily, fontWeight: 400, fontSize: fontSizes.xs,  lineHeight: 1.5 },
    overline: { fontFamily, fontWeight: 500, fontSize: fontSizes.xs, textTransform: 'uppercase', letterSpacing: '0.08em' },
  },

  shape: {
    borderRadius: 7,   // matches `border-radius: 7px` on buttons
  },

  shadows: [
    'none',
    shadows.xs,        // elevation 1
    shadows.sm,        // elevation 2
    shadows.md,        // elevation 3
    shadows.primaryXs, // elevation 4
    shadows.primarySm, // elevation 5
    shadows.primaryMd, // elevation 6
    shadows.primaryLg, // elevation 7
    shadows.overlay,   // elevation 8
    shadows.float,     // elevation 9
    shadows.text,      // elevation 10
    // MUI v4 requires exactly 25 shadow entries
    shadows.primaryLg, shadows.primaryLg, shadows.primaryLg, shadows.primaryLg,
    shadows.primaryLg, shadows.primaryLg, shadows.primaryLg, shadows.primaryLg,
    shadows.primaryLg, shadows.primaryLg, shadows.primaryLg, shadows.primaryLg,
    shadows.primaryLg, shadows.primaryLg,
  ] as any,

  overrides: {
    MuiCssBaseline: {
      '@global': {
        // Register ADNOC Sans @font-face rules here if you prefer JS-only setup
        // (alternatively add them in your global CSS file — see file header)
        body: {
          fontFamily,
          backgroundColor: colors.background,
          color: colors.textPrimary,
        },
      },
    },

    // ── Buttons ──────────────────────────────────────────────────────────────
    MuiButton: {
      root: {
        borderRadius: 7,
        fontSize: fontSizes.base,
        fontWeight: 500,
        textTransform: 'none',
        fontFamily,
      },
      contained: {
        boxShadow: shadows.primaryXs,
        '&:hover': {
          boxShadow: shadows.primaryLg,
        },
      },
      containedPrimary: {
        background: `linear-gradient(135deg, ${colors.primaryMain} 0%, ${colors.primaryLight} 100%)`,
        color: '#ffffff',
        '&:hover': {
          background: `linear-gradient(135deg, ${colors.primaryDark} 0%, ${colors.primaryMain} 100%)`,
        },
      },
      outlined: {
        borderColor: colors.borderSubtle,
        '&:hover': {
          borderColor: colors.primaryMain,
          backgroundColor: colors.activeBg,
        },
      },
      outlinedPrimary: {
        borderColor: colors.primaryMain,
        '&:hover': {
          backgroundColor: colors.activeBg,
        },
      },
    },

    MuiIconButton: {
      root: {
        '&:hover': {
          backgroundColor: colors.activeBg,
        },
      },
    },

    // ── Cards ─────────────────────────────────────────────────────────────────
    MuiCard: {
      root: {
        borderRadius: 12,
        boxShadow: shadows.md,
        '&:hover': {
          boxShadow: shadows.primaryMd,
        },
      },
    },

    MuiPaper: {
      rounded: {
        borderRadius: 12,
      },
      elevation1: { boxShadow: shadows.xs },
      elevation2: { boxShadow: shadows.sm },
      elevation3: { boxShadow: shadows.md },
      elevation8: { boxShadow: shadows.overlay },   // dialogs / menus
    },

    // ── Inputs / Form fields ──────────────────────────────────────────────────
    MuiOutlinedInput: {
      root: {
        borderRadius: 7,
        '&:hover $notchedOutline': {
          borderColor: colors.primaryMain,
        },
        '&$focused $notchedOutline': {
          borderColor: colors.primaryMain,
          borderWidth: 2,
        },
      },
      notchedOutline: {
        borderColor: colors.lightGray,
      },
    },

    MuiInputLabel: {
      root: {
        color: colors.textSecondary,
        fontFamily,
        fontSize: fontSizes.base,
        '&$focused': {
          color: colors.primaryMain,
        },
      },
    },

    // ── Chip ─────────────────────────────────────────────────────────────────
    MuiChip: {
      root: {
        borderRadius: 6,
        fontFamily,
        fontSize: fontSizes.sm,
      },
      colorPrimary: {
        backgroundColor: colors.activeBg,
        color: colors.primaryMain,
      },
    },

    // ── Table ─────────────────────────────────────────────────────────────────
    MuiTableHead: {
      root: {
        backgroundColor: colors.background,
      },
    },
    MuiTableCell: {
      head: {
        fontWeight: 600,
        color: colors.textSecondary,
        fontFamily,
        fontSize: fontSizes.sm,
      },
      body: {
        fontFamily,
        fontSize: fontSizes.sm,
        color: colors.textPrimary,
      },
    },

    // ── Dialogs ───────────────────────────────────────────────────────────────
    MuiDialog: {
      paper: {
        borderRadius: 12,
        boxShadow: shadows.overlay,
      },
    },

    // ── Snackbar ──────────────────────────────────────────────────────────────
    MuiSnackbarContent: {
      root: {
        borderRadius: 8,
        boxShadow: shadows.float,
        fontFamily,
      },
    },

    // ── Tabs ──────────────────────────────────────────────────────────────────
    MuiTab: {
      root: {
        fontFamily,
        fontWeight: 500,
        fontSize: fontSizes.sm,
        textTransform: 'none',
        minWidth: 'auto',
      },
    },

    // ── Tooltip ───────────────────────────────────────────────────────────────
    MuiTooltip: {
      tooltip: {
        fontFamily,
        fontSize: fontSizes.xs,
        borderRadius: 6,
        boxShadow: shadows.float,
      },
    },
  },

  props: {
    MuiButton:      { disableElevation: false },
    MuiTextField:   { variant: 'outlined' },
    MuiSelect:      { variant: 'outlined' },
    MuiFormControl: { variant: 'outlined' },
    MuiCard:        { elevation: 0 },
    MuiPaper:       { elevation: 0 },
  },
};

// ─── Compiled theme instance (plain MUI v4) ───────────────────────────────────

export const adnocTheme = createTheme(adnocThemeOptions);

// ─── MUI v5-format options for createUnifiedTheme (@backstage/theme) ─────────
// createUnifiedTheme uses MUI v5 internally, so it needs `palette.mode`,
// `components[x].styleOverrides`, and `components[x].defaultProps` instead of
// the v4 `palette.type`, `overrides`, and `props` keys.

export const adnocUnifiedThemeOptions = {
  palette: {
    mode: 'light' as const,
    primary: {
      main:         colors.primaryMain,
      dark:         colors.primaryDark,
      light:        colors.primaryLight,
      contrastText: '#ffffff',
    },
    secondary: {
      main:         colors.primaryLight,
      dark:         colors.primaryMain,
      light:        colors.activeBg,
      contrastText: '#ffffff',
    },
    error:   { main: colors.error },
    warning: { main: colors.warning },
    info:    { main: colors.info },
    success: { main: colors.success },
    text: {
      primary:   colors.textPrimary,
      secondary: colors.textSecondary,
      disabled:  colors.coolGray,
    },
    background: {
      default: colors.background,
      paper:   colors.paper,
    },
    divider: colors.lightGray,
  },

  typography: {
    fontFamily,
    fontSize: 16,
    h1: { fontFamily, fontWeight: 700, fontSize: fontSizes['4xl'], lineHeight: 1.25 },
    h2: { fontFamily, fontWeight: 700, fontSize: fontSizes['3xl'], lineHeight: 1.25 },
    h3: { fontFamily, fontWeight: 600, fontSize: fontSizes['2xl'], lineHeight: 1.25 },
    h4: { fontFamily, fontWeight: 600, fontSize: fontSizes.xl,    lineHeight: 1.25 },
    h5: { fontFamily, fontWeight: 500, fontSize: fontSizes.lg,    lineHeight: 1.5  },
    h6: { fontFamily, fontWeight: 500, fontSize: fontSizes.base,  lineHeight: 1.5  },
    subtitle1: { fontFamily, fontWeight: 500, fontSize: fontSizes.base, lineHeight: 1.5 },
    subtitle2: { fontFamily, fontWeight: 500, fontSize: fontSizes.sm,   lineHeight: 1.5 },
    body1: { fontFamily, fontWeight: 400, fontSize: fontSizes.base, lineHeight: 1.5 },
    body2: { fontFamily, fontWeight: 400, fontSize: fontSizes.sm,   lineHeight: 1.5 },
    button:  { fontFamily, fontWeight: 500, fontSize: fontSizes.base, textTransform: 'none' as const },
    caption: { fontFamily, fontWeight: 400, fontSize: fontSizes.xs,  lineHeight: 1.5 },
    overline: { fontFamily, fontWeight: 500, fontSize: fontSizes.xs, textTransform: 'uppercase' as const, letterSpacing: '0.08em' },
  },

  shape: { borderRadius: 7 },

  components: {
    MuiCssBaseline: {
      styleOverrides: {
        body: { fontFamily, backgroundColor: colors.background, color: colors.textPrimary },
      },
    },
    MuiButton: {
      defaultProps: { disableElevation: false },
      styleOverrides: {
        root: { borderRadius: 7, fontSize: fontSizes.base, fontWeight: 500, textTransform: 'none' as const, fontFamily },
        contained: { boxShadow: shadows.primaryXs, '&:hover': { boxShadow: shadows.primaryLg } },
        containedPrimary: {
          background: `linear-gradient(135deg, ${colors.primaryMain} 0%, ${colors.primaryLight} 100%)`,
          color: '#ffffff',
          '&:hover': { background: `linear-gradient(135deg, ${colors.primaryDark} 0%, ${colors.primaryMain} 100%)` },
        },
        outlined: {
          borderColor: colors.borderSubtle,
          '&:hover': { borderColor: colors.primaryMain, backgroundColor: colors.activeBg },
        },
        outlinedPrimary: { borderColor: colors.primaryMain, '&:hover': { backgroundColor: colors.activeBg } },
      },
    },
    MuiIconButton: {
      styleOverrides: {
        root: { '&:hover': { backgroundColor: colors.activeBg } },
      },
    },
    MuiCard: {
      defaultProps: { elevation: 0 },
      styleOverrides: {
        root: { borderRadius: 12, boxShadow: shadows.md, '&:hover': { boxShadow: shadows.primaryMd } },
      },
    },
    MuiPaper: {
      defaultProps: { elevation: 0 },
      styleOverrides: {
        rounded: { borderRadius: 12 },
      },
    },
    MuiOutlinedInput: {
      styleOverrides: {
        root: {
          borderRadius: 7,
          '&:hover .MuiOutlinedInput-notchedOutline': { borderColor: colors.primaryMain },
          '&.Mui-focused .MuiOutlinedInput-notchedOutline': { borderColor: colors.primaryMain, borderWidth: 2 },
        },
        notchedOutline: { borderColor: colors.lightGray },
      },
    },
    MuiInputLabel: {
      styleOverrides: {
        root: { color: colors.textSecondary, fontFamily, fontSize: fontSizes.base, '&.Mui-focused': { color: colors.primaryMain } },
      },
    },
    MuiTextField: { defaultProps: { variant: 'outlined' as const } },
    MuiSelect:    { defaultProps: { variant: 'outlined' as const } },
    MuiFormControl: { defaultProps: { variant: 'outlined' as const } },
    MuiChip: {
      styleOverrides: {
        root: { borderRadius: 6, fontFamily, fontSize: fontSizes.sm },
        colorPrimary: { backgroundColor: colors.activeBg, color: colors.primaryMain },
      },
    },
    MuiTableHead: {
      styleOverrides: { root: { backgroundColor: colors.background } },
    },
    MuiTableCell: {
      styleOverrides: {
        head: { fontWeight: 600, color: colors.textSecondary, fontFamily, fontSize: fontSizes.sm },
        body: { fontFamily, fontSize: fontSizes.sm, color: colors.textPrimary },
      },
    },
    MuiDialog: {
      styleOverrides: { paper: { borderRadius: 12, boxShadow: shadows.overlay } },
    },
    MuiSnackbarContent: {
      styleOverrides: { root: { borderRadius: 8, boxShadow: shadows.float, fontFamily } },
    },
    MuiTab: {
      styleOverrides: {
        root: { fontFamily, fontWeight: 500, fontSize: fontSizes.sm, textTransform: 'none' as const, minWidth: 'auto' },
      },
    },
    MuiTooltip: {
      styleOverrides: {
        tooltip: { fontFamily, fontSize: fontSizes.xs, borderRadius: 6, boxShadow: shadows.float },
      },
    },
  },
};

// ─── Named color / token exports (for use in makeStyles / sx props) ───────────

export { colors as adnocColors, shadows as adnocShadows, fontSizes as adnocFontSizes, fontFamily as adnocFontFamily };
