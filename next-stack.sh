#!/bin/bash
#!/usr/bin/expect -f

figlet "TECHSTACK" | lolcat

# Gather information about the project
echo -n "Enter the project name: "
read project_name
echo -n "Enter the project description: "
read project_description

# Set up the project
echo "Setting up the project..."
npx create-next-app@latest $project_name

cd $project_name

# Add project dependencies
figlet "Dependencies" | lolcat
npx shadcn-ui@latest init
npx shadcn-ui@latest add dropdown-menu button
echo "Choose components to install:"
npx shadcn-ui@latest add
echo "Installing some more dependencies..."
npm install --loglevel=error geist date-fns lodash lucide-react @clerk/nextjs @prisma/client next-themes react-hook-form @hookform/resolvers zod @vercel/analytics @vercel/speed-insights zod
npm install -D --loglevel=error @ianvs/prettier-plugin-sort-imports eslint-config-prettier eslint-plugin-prettier eslint-plugin-react eslint-plugin-tailwindcss husky lint-staged prettier prettier-plugin-tailwindcss prisma @commitlint/cli @commitlint/config-conventional

# Initialize technologies and config files
figlet "Configuration" | lolcat
echo "Making project configurations..."
rm ./tailwind.config.ts ./public/next.svg ./public/vercel.svg ./app/favicon.ico ./app/globals.css
mkdir config types hooks
touch middleware.ts ./config/app.ts ./lib/db.ts ./lib/fonts.ts ./lib/constants.ts ./types/index.d.ts ./types/schemas.ts ./components/ui/icons.tsx ./public/favicon.ico ./public/robots.txt ./hooks/use-debounce.ts .env.example .env .prettierignore prettier.config.js .lintstagedrc.js .eslintignore .commitlintrc.json .editorconfig ./components/theme-provider.tsx ./components/theme-toggle.tsx ./components/navbar.tsx
npx prisma init > /dev/null 
npx husky-init > /dev/null && npm install > /dev/null
touch ./.husky/commit-msg
chmod +x ./.husky/commit-msg

cat << 'EOF' > ./.husky/commit-msg
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

npx commitlint --edit $1

# TODO: chmod +x .husky/commit-msg -> Execute this in the terminal to let the script run
EOF

cat << 'EOF' > ./types/index.d.ts
import { User } from "@prisma/client"
import type { Icon } from "lucide-react"
import { Icons } from "@/components/icons"

export type AppConfig = {
  name: string
  description: string
  url: string
}
EOF

cat << EOF > ./config/app.ts
import { AppConfig } from "@/types"

export const appConfig: AppConfig = {
  name: "${project_name}",
  description: "${project_description}",
  url: "https://github.com/razlevio",
}
EOF

cat << 'EOF' > ./components/theme-provider.tsx
"use client"

import { ThemeProvider as NextThemesProvider } from "next-themes"
import { type ThemeProviderProps } from "next-themes/dist/types"

export function ThemeProvider({ children, ...props }: ThemeProviderProps) {
  return <NextThemesProvider {...props}>{children}</NextThemesProvider>
}
EOF

cat << 'EOF' > ./components/theme-toggle.tsx
"use client"

import * as React from "react"
import { Moon, Sun } from "lucide-react"
import { useTheme } from "next-themes"

import { Button } from "@/components/ui/button"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"

export function ThemeToggle() {
  const { setTheme } = useTheme()

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button variant="outline" size="icon">
          <Sun className="h-[1.2rem] w-[1.2rem] rotate-0 scale-100 transition-all dark:-rotate-90 dark:scale-0" />
          <Moon className="absolute h-[1.2rem] w-[1.2rem] rotate-90 scale-0 transition-all dark:rotate-0 dark:scale-100" />
          <span className="sr-only">Toggle theme</span>
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end">
        <DropdownMenuItem onClick={() => setTheme("light")}>
          Light
        </DropdownMenuItem>
        <DropdownMenuItem onClick={() => setTheme("dark")}>
          Dark
        </DropdownMenuItem>
        <DropdownMenuItem onClick={() => setTheme("system")}>
          System
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  )
}
EOF

cat << 'EOF' > ./components/navbar.tsx
"use client"

import { usePathname } from "next/navigation"
import { UserButton } from "@clerk/nextjs"
import { cn } from "@/lib/utils"
import Link from "next/link"

interface NavigationData {
	name: string
	href: string
}

/**
 * Represents a navigation bar component
 */
export function Navbar() {
	const navigationData: NavigationData[] = [
		{ name: "dashboard", href: "/dashboard" },
		{ name: "control", href: "/control" },
	]

	const pathname = usePathname()

	return (
		// <div className="sticky top-0 z-50 shadow bg-base-100">
		// 	<div className="px-4 mx-auto navbar max-w-7xl">
		// 		<div className="navbar-start">
		// 			{/* Mobile Navigation */}
		// 			<div className="dropdown sm:hidden">
		// 				{/* Mobile Navigation Trigger */}
		// 				<label tabIndex={0} className="btn btn-circle btn-ghost">
		// 					{/* Hamburger Icon */}
		// 					<svg
		// 						xmlns="http://www.w3.org/2000/svg"
		// 						className="w-5 h-5"
		// 						fill="none"
		// 						viewBox="0 0 24 24"
		// 						stroke="currentColor"
		// 					>
		// 						<path
		// 							strokeLinecap="round"
		// 							strokeLinejoin="round"
		// 							strokeWidth="2"
		// 							d="M4 6h16M4 12h16M4 18h7"
		// 						/>
		// 					</svg>
		// 				</label>
		// 				{/* Mobile Navigation Menu */}
		// 				<ul
		// 					tabIndex={0}
		// 					className="menu dropdown-content rounded-box menu-sm z-[1] mt-3 w-52 gap-1 bg-base-100 p-2 font-bold shadow"
		// 				>
		// 					{navigationData.map((item) => (
		// 						<li key={item.href}>
		// 							<Link href={item.href}>{item.name}</Link>
		// 						</li>
		// 					))}
		// 				</ul>
		// 			</div>
		// 			{/* Desktop Navigation */}
		// 			<div className="hidden gap-4 sm:flex">
		// 				{navigationData.map((item) => (
		// 					<Link
		// 						key={item.name}
		// 						href={item.href}
		// 						className={cn(
		// 							pathname.startsWith(item.href)
		// 								? "border-primary text-base-content"
		// 								: pathname === "/"
		// 								? "border-transparent text-base-content hover:border-primary hover:text-base-content"
		// 								: "border-transparent text-base-content/60 hover:border-primary hover:text-base-content",
		// 							"text-md flex h-full items-center border-b-2 px-1 pt-1 font-medium"
		// 						)}
		// 						aria-current={pathname === item.href ? "page" : undefined}
		// 					>
		// 						{item.name}
		// 					</Link>
		// 				))}
		// 			</div>
		// 		</div>
		// 		{/* Logo */}
		// 		<div className="navbar-center">
		// 			<Link href="/" className="flex items-center rounded-lg btn btn-ghost">
		// 				<Logo src="/logos/logo-symbol-hd.png" />
		// 			</Link>
		// 		</div>
		// 		{/* User Controls */}
		// 		<div className="navbar-end">
		// 			<div className="btn btn-circle btn-ghost">
		// 				<UserButton afterSignOutUrl="/" />
		// 			</div>
		// 			<ThemePicker />
		// 		</div>
		// 	</div>
		// </div>
    <div></div>
	)
}

EOF

cat << 'EOF' > ./middleware.ts
import { authMiddleware } from "@clerk/nextjs"

export default authMiddleware({publicRoutes: ['/api/calculate']});

export const config = {
	matcher: ["/((?!.+\\.[\\w]+$|_next).*)", "/", "/(api|trpc)(.*)"],
}
EOF

cat << 'EOF' > ./styles/globals.css
@tailwind base;
@tailwind components;
@tailwind utilities;
 
@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;

    --card: 0 0% 100%;
    --card-foreground: 222.2 84% 4.9%;
 
    --popover: 0 0% 100%;
    --popover-foreground: 222.2 84% 4.9%;
 
    --primary: 222.2 47.4% 11.2%;
    --primary-foreground: 210 40% 98%;
 
    --secondary: 210 40% 96.1%;
    --secondary-foreground: 222.2 47.4% 11.2%;
 
    --muted: 210 40% 96.1%;
    --muted-foreground: 215.4 16.3% 46.9%;
 
    --accent: 210 40% 96.1%;
    --accent-foreground: 222.2 47.4% 11.2%;
 
    --destructive: 0 84.2% 60.2%;
    --destructive-foreground: 210 40% 98%;

    --border: 214.3 31.8% 91.4%;
    --input: 214.3 31.8% 91.4%;
    --ring: 222.2 84% 4.9%;
 
    --radius: 0.5rem;
  }
 
  .dark {
    --background: 222.2 84% 4.9%;
    --foreground: 210 40% 98%;
 
    --card: 222.2 84% 4.9%;
    --card-foreground: 210 40% 98%;
 
    --popover: 222.2 84% 4.9%;
    --popover-foreground: 210 40% 98%;
 
    --primary: 210 40% 98%;
    --primary-foreground: 222.2 47.4% 11.2%;
 
    --secondary: 217.2 32.6% 17.5%;
    --secondary-foreground: 210 40% 98%;
 
    --muted: 217.2 32.6% 17.5%;
    --muted-foreground: 215 20.2% 65.1%;
 
    --accent: 217.2 32.6% 17.5%;
    --accent-foreground: 210 40% 98%;
 
    --destructive: 0 62.8% 30.6%;
    --destructive-foreground: 210 40% 98%;
 
    --border: 217.2 32.6% 17.5%;
    --input: 217.2 32.6% 17.5%;
    --ring: 212.7 26.8% 83.9%;
  }
}
 
@layer base {
  * {
    @apply border-border;
  }
  body {
    @apply bg-background text-foreground;
  }
}

code {
	@apply relative rounded bg-muted px-[0.3rem] py-[0.2rem] font-geistMono text-sm font-semibold
}

hr {
  border: 0;
  height: 1px;
  background-image: linear-gradient(
    to right, 
    hsl(var(--bc) / 0.07), /* Start with transparent color */
    hsl(var(--bc) / 0.35), /* Middle with more opacity */
    hsl(var(--bc) / 0.07) /* End with transparent color */
  );
}
EOF

cat << 'EOF' > ./hooks/use-debounce.ts
import { useEffect, useState } from "react"

/**
 * A hook that provides a debounced value of the given input.
 * It delays updating the value until after the specified delay has passed, which is useful for reducing the frequency of updates during rapid input.
 * @param {T} value - The value to debounce.
 * @param {number} [delay=500] - The time in milliseconds to delay the update of the debounced value. Defaults to 500ms if not provided.
 * @returns {T} - The debounced value.
 */
export function useDebounce<T>(value: T, delay?: number): T {
	const [debouncedValue, setDebouncedValue] = useState<T>(value)

	useEffect(() => {
		// Set up a timer to update the debounced value after the specified delay
		const timer = setTimeout(() => setDebouncedValue(value), delay || 500)

		// Clean up the timer when the value or delay changes, or when the component unmounts
		return () => clearTimeout(timer)
	}, [value, delay])

	return debouncedValue
}
EOF

cat << 'EOF' > ./app/layout.tsx
import "@/styles/globals.css"
import { Metadata } from "next"
import { Analytics } from "@vercel/analytics/react"
import { SpeedInsights } from "@vercel/speed-insights/next"
import { appConfig } from "@/config/app"
import { geist, geistMono } from "@/lib/fonts"
import { cn } from "@/lib/utils"
import { ThemeProvider } from "@/components/theme-provider"

export const metadata: Metadata = {
  title: {
    default: appConfig.name,
    template: "%s | " + appConfig.name,
  },
  applicationName: appConfig.name,
  description: appConfig.description,
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      'max-video-preview': -1,
      'max-image-preview': 'large',
      'max-snippet': -1,
    },
  },
  authors: [
    {
      name: "razlevio",
      url: "https://github.com/razlevio",
    },
  ],
  creator: "razlevio",
  icons: {
    icon: "/favicon.png",
    shortcut: "/favicon.png",
  },
  verification: {
    google: 'google',
    yandex: 'yandex',
  },
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" className={cn("h-full tracking-tighter", geist.className, geist.variable, geistMono.variable)}>
        <ThemeProvider attribute="class" defaultTheme="system" enableSystem disableTransitionOnChange>
          <body>
            {children}
            <Analytics />
            <SpeedInsights />
          </body>
        </ThemeProvider>
    </html>
  )
}
EOF

cat << 'EOF' > ./app/page.tsx
export default function RootPage() {
  return (
    <main className="p-6 mx-auto max-w-7xl sm:px-4">
      <h1 className="font-extrabold text-7xl">Hello World</h1>
    </main>
  )
}
EOF

cat << 'EOF' > ./components/ui/icons.tsx
import {
  AlertTriangle,
  File,
  FileText,
  HelpCircle,
  Image,
  Loader2,
  Plus,
  Settings,
  Trash,
  User,
} from "lucide-react"

export const Icons = {
  alert: AlertTriangle,
  file: File,
  fileText: FileText,
  help: HelpCircle,
  image: Image,
  loader: Loader2,
  plus: Plus,
  settings: Settings,
  trash: Trash,
  user: User,
}
EOF

cat << 'EOF' > ./lib/db.ts
import { PrismaClient } from "@prisma/client"

declare global {
  // eslint-disable-next-line no-var
  var cachedPrisma: PrismaClient
}

let prisma: PrismaClient
if (process.env.NODE_ENV === "production") {
  prisma = new PrismaClient()
} else {
  if (!global.cachedPrisma) {
    global.cachedPrisma = new PrismaClient()
  }
  prisma = global.cachedPrisma
}

export const db = prisma
EOF

cat << 'EOF' > ./lib/fonts.ts
import { GeistSans } from 'geist/font/sans';
import { GeistMono } from 'geist/font/mono';

export const geist = GeistSans
export const geistMono = GeistMono
EOF


cat << 'EOF' > ./.env.example
# TODO: Copy .env.example to .env and update the variables.
# -----------------------------------------------------------------------------
# App
# -----------------------------------------------------------------------------
NEXT_PUBLIC_APP_URL=http://localhost:3000 # http://localhost:3000 in development | https://app.domain.com in production
NODE_ENV="development" # development | production

# -----------------------------------------------------------------------------
# Authentication (Clerk.js)
# -----------------------------------------------------------------------------
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=
CLERK_SECRET_KEY=


# -----------------------------------------------------------------------------
# Database
# -----------------------------------------------------------------------------
DATABASE_URL=""

# -----------------------------------------------------------------------------
# Subscriptions (Stripe)
# -----------------------------------------------------------------------------
STRIPE_API_KEY=
STRIPE_WEBHOOK_SECRET=
STRIPE_PRO_MONTHLY_PLAN_ID=

# -----------------------------------------------------------------------------
# Email (Postmark)
# -----------------------------------------------------------------------------
SMTP_FROM=
POSTMARK_API_TOKEN=
POSTMARK_SIGN_IN_TEMPLATE=
POSTMARK_ACTIVATION_TEMPLATE=
EOF

cat << 'EOF' > ./.eslintrc.json
{
  "$schema": "https://json.schemastore.org/eslintrc",
  "root": true,
  "extends": [
    "next/core-web-vitals",
    "prettier",
    "plugin:tailwindcss/recommended"
  ],
  "plugins": ["tailwindcss"],
  "rules": {
    "tailwindcss/no-custom-classname": "off",
    "tailwindcss/classnames-order": "error"
  },
  "settings": {
    "tailwindcss": {
      "callees": ["cn"],
			"config": "tailwind.config.js"
    },
    "next": {
      "rootDir": true
    }
  }
}
EOF

cat << 'EOF' > ./.eslintignore
dist/*
.cache
public
node_modules
*.esm.js
EOF

cat << 'EOF' > ./.commitlintrc.json
{
  "extends": ["@commitlint/config-conventional"]
}
EOF

cat << 'EOF' > ./.gitignore
# See https://help.github.com/articles/ignoring-files/ for more about ignoring files.

# dependencies
/node_modules
/.pnp
.pnp.js

# testing
/coverage

# next.js
/.next/
/out/

# production
/build

# misc
.DS_Store
*.pem

# debug
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# local env files
.env*.local
.env

# vercel
.vercel

# typescript
*.tsbuildinfo
next-env.d.ts

.vscode
EOF

cat << 'EOF' > ./prettier.config.js
/** @type {import('prettier').Config} */
module.exports = {
  endOfLine: "lf",
  semi: false,
  singleQuote: false,
  tabWidth: 2,
  trailingComma: "es5",
	importOrder: [
	    "^(react/(.*)$)|^(react$)",
	    "^(next/(.*)$)|^(next$)",
	    "<THIRD_PARTY_MODULES>",
	    "",
	    "^types$",
	    "^@/env(.*)$",
	    "^@/types/(.*)$",
	    "^@/config/(.*)$",
	    "^@/lib/(.*)$",
	    "^@/hooks/(.*)$",
	    "^@/components/ui/(.*)$",
	    "^@/components/(.*)$",
	    "^@/styles/(.*)$",
	    "^@/app/(.*)$",
	    "",
	    "^[./]",
	],
  importOrderSeparation: false,
  importOrderSortSpecifiers: true,
  importOrderBuiltinModulesToTop: true,
  importOrderParserPlugins: ["typescript", "jsx", "decorators-legacy"],
  importOrderMergeDuplicateImports: true,
  importOrderCombineTypeAndValueImports: true,
  plugins: ["@ianvs/prettier-plugin-sort-imports"],
}
EOF

cat << 'EOF' > ./.prettierignore
cache
.cache
package.json
package-lock.json
public
CHANGELOG.md
.yarn
dist
node_modules
.next
build
EOF

cat << 'EOF' > ./next.config.js
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
}

module.exports = nextConfig
EOF

cat << 'EOF' > ./tailwind.config.js
const { fontFamily } = require("tailwindcss/defaultTheme")

/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: ["class"],
  content: [
    './pages/**/*.{ts,tsx}',
    './components/**/*.{ts,tsx}',
    './app/**/*.{ts,tsx}',
    './src/**/*.{ts,tsx}',
  ],
  prefix: "",
  theme: {
    container: {
      center: true,
      padding: "2rem",
      screens: {
        "2xl": "1400px",
      },
    },
    extend: {
      colors: {
        border: "hsl(var(--border))",
        input: "hsl(var(--input))",
        ring: "hsl(var(--ring))",
        background: "hsl(var(--background))",
        foreground: "hsl(var(--foreground))",
        primary: {
          DEFAULT: "hsl(var(--primary))",
          foreground: "hsl(var(--primary-foreground))",
        },
        secondary: {
          DEFAULT: "hsl(var(--secondary))",
          foreground: "hsl(var(--secondary-foreground))",
        },
        destructive: {
          DEFAULT: "hsl(var(--destructive))",
          foreground: "hsl(var(--destructive-foreground))",
        },
        muted: {
          DEFAULT: "hsl(var(--muted))",
          foreground: "hsl(var(--muted-foreground))",
        },
        accent: {
          DEFAULT: "hsl(var(--accent))",
          foreground: "hsl(var(--accent-foreground))",
        },
        popover: {
          DEFAULT: "hsl(var(--popover))",
          foreground: "hsl(var(--popover-foreground))",
        },
        card: {
          DEFAULT: "hsl(var(--card))",
          foreground: "hsl(var(--card-foreground))",
        },
      },
      borderRadius: {
        lg: "var(--radius)",
        md: "calc(var(--radius) - 2px)",
        sm: "calc(var(--radius) - 4px)",
      },
      keyframes: {
        "accordion-down": {
          from: { height: "0" },
          to: { height: "var(--radix-accordion-content-height)" },
        },
        "accordion-up": {
          from: { height: "var(--radix-accordion-content-height)" },
          to: { height: "0" },
        },
      },
      animation: {
        "accordion-down": "accordion-down 0.2s ease-out",
        "accordion-up": "accordion-up 0.2s ease-out",
      },
      fontFamily: {
        geist: ["var(--font-geist-sans)", ...fontFamily.sans],
        geistMono: ['var(--font-geist-mono)', ...fontFamily.mono],
      },
    },
  },
  plugins: [require("tailwindcss-animate")],
}
EOF


cat << 'EOF' > ./.husky/pre-commit
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

npx lint-staged --concurrent false
EOF

chmod +x ./.husky/pre-commit

cat << 'EOF' > ./.lintstagedrc.js
const path = require("path")

const buildEslintCommand = (filenames) =>
	`next lint --fix --file ${filenames
		.map((f) => path.relative(process.cwd(), f))
		.join(" --file ")}`

module.exports = {
	"*.{js,jsx,ts,tsx}": [buildEslintCommand, "eslint --fix", "eslint"],
}
EOF

cat << 'EOF' > ./.editorconfig
# editorconfig.org
root = true

[*]
charset = utf-8
end_of_line = lf
indent_size = 2
indent_style = tab
insert_final_newline = true
trim_trailing_whitespace = true

[*.py]
indent_size = 4
EOF

cat << 'EOF' > ./types/schemas.ts
import { z } from "zod"

// EXAMPLE SCHEMA
export const AddReportSchema = z.object({
	date: z.date(),
	project_id: z.string().min(1, { message: "Need to choose project" }),
	report_status: z.string().min(1, { message: "Need to choose status" }),
	amount_reported: z.number(),
	amount_approved: z.number(),
	assignee: z.string().min(1, { message: "Need to choose assignee" }),
})

export type AddReport = z.infer<typeof AddReportSchema>
EOF

cat << 'EOF' > ./public/robots.txt
# *
User-agent: *
Allow: /
EOF

cat << 'EOF' > ./README.md
# ${project_name}
## Description
${project_description}
EOF

# Commiting the project initializition
git add . && git commit -m "chore(project-setup): establish structure and configuration"

# Syncing with GitHub repo
# git remote add origin git@github.com:razlevio/$project_name.git
# git branch -M main
# git push -u origin main


figlet "Happy Coding!" | lolcat
echo ""
echo "To start the project: cd $project_name -> npm run dev"
echo ""
echo "To push the project to GitHub repository:"
echo ""
echo "git remote add origin git@github.com:razlevio/$project_name.git"
echo "git branch -M main"
echo "git push -u origin main"
echo ""