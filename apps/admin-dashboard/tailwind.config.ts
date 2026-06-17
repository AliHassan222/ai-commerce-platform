import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./lib/**/*.{js,ts,jsx,tsx,mdx}"
  ],
  theme: {
    extend: {
      colors: {
        background: "#f8f9ff",
        surface: "#f8f9ff",
        "surface-container-lowest": "#ffffff",
        "surface-container-low": "#eff4ff",
        "surface-container": "#e5eeff",
        "surface-container-high": "#dce9ff",
        "surface-container-highest": "#d3e4fe",
        "on-surface": "#0b1c30",
        "on-surface-variant": "#434656",
        primary: "#003ec7",
        "primary-container": "#0052ff",
        "on-primary": "#ffffff",
        secondary: "#565e74",
        "secondary-container": "#dae2fd",
        "on-secondary-container": "#5c647a",
        tertiary: "#952200",
        "tertiary-fixed": "#ffdbd2",
        "tertiary-container": "#bf3003",
        outline: "#737688",
        "outline-variant": "#c3c5d9",
        error: "#ba1a1a"
      },
      borderRadius: {
        DEFAULT: "0.125rem",
        lg: "0.25rem",
        xl: "0.5rem",
        full: "0.75rem"
      },
      spacing: {
        xs: "4px",
        sm: "8px",
        md: "16px",
        lg: "24px",
        xl: "32px",
        "2xl": "48px",
        "sidebar-width": "240px",
        "container-max": "1440px"
      },
      fontFamily: {
        sans: ["var(--font-admin)", "Inter", "ui-sans-serif", "system-ui"],
        mono: ["var(--font-code)", "JetBrains Mono", "ui-monospace", "SFMono-Regular"]
      },
      boxShadow: {
        panel: "0 10px 30px rgba(11, 28, 48, 0.06)"
      }
    }
  },
  plugins: []
};

export default config;
