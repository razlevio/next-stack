#!/bin/bash
#!/usr/bin/expect -f

# Display a startup message
figlet "NEXTSTACK" | lolcat

# Section 1: Project Information Gathering
# ----------------------------------------
echo -n "Enter the project name: "
read project_name
echo -n "Enter the project description: "
read project_description
echo "Are you using Prisma (y/n)"
read using_prisma
echo "Are you deploying on Vercel? (y/n)"
read deploying_on_vercel

# Section 2: Project Setup
# -------------------------
echo "Setting up the project..."
npx create-next-app@latest $project_name
cd $project_name

# Section 3: Dependencies Installation
# -------------------------------------
figlet "Dependencies" | lolcat
echo "Installing dependencies..."
npx shadcn-ui@latest init
npx shadcn-ui@latest add dropdown-menu button alert-dialog dialog label 
echo "Choose components to install:"
npx shadcn-ui@latest add

echo "Installing some more dependencies..."
# Install main application dependencies based on user choice
if [ "$using_prisma" = "y" ]; then
    # Prisma
    npm install --loglevel=error lucide-react geist next-themes @clerk/nextjs zustand zod react-hook-form @hookform/resolvers usehooks-ts sonner lodash date-fns @prisma/client
    npx prisma init > /dev/null
else
    npm install --loglevel=error lucide-react geist next-themes @clerk/nextjs zustand zod react-hook-form @hookform/resolvers usehooks-ts sonner lodash date-fns
fi

# Conditional installation for Vercel
if [ "$deploying_on_vercel" = "y" ]; then
    npm install --loglevel=error @vercel/analytics @vercel/speed-insights
fi

# Install dev dependencies
npm install -D --loglevel=error eslint-config-prettier eslint-plugin-prettier eslint-plugin-react eslint-plugin-tailwindcss prettier prettier-plugin-tailwindcss @ianvs/prettier-plugin-sort-imports husky lint-staged @commitlint/cli @commitlint/config-conventional

# Section 4: Project Configuration and File Creation
# -------------------------------------------------
figlet "Configuration" | lolcat
echo "Making project configurations..."
rm ./public/next.svg ./public/vercel.svg ./app/favicon.ico ./app/globals.css
mkdir components/modals components/providers config hooks scripts types
touch middleware.ts \
prettier.config.js \
.env \
.prettierignore \
.lintstagedrc.js \
.eslintignore \
.commitlintrc.json \
.editorconfig \
./public/favicon.ico \
./public/robots.txt \
./components/providers/theme-provider.tsx \
./components/providers/modal-provider.tsx \
./components/modals/settings-modal.tsx \
./components/modals/confirm-modal.tsx \
./components/theme-toggle.tsx \
./components/navbar.tsx \
./components/ui/icons.tsx \
./config/app.ts \
./hooks/use-debounce.tsx \
./hooks/use-origin.tsx \
./hooks/use-search.tsx \
./hooks/use-settings.tsx \
./lib/db.ts \
./lib/fonts.ts \
./lib/constants.ts \
./types/index.d.ts \
./types/schemas.ts 

# Initialize Husky for Git hooks
npx husky-init && npm install
jq '.scripts.test = "echo \"No tests specified\" && exit 0"' package.json > temp.json && mv temp.json package.json
npx husky add .husky/commit-msg 'npx commitlint --edit "$1"'
npx husky add .husky/pre-commit 'npx lint-staged --concurrent false'


# Section 5: File Content Creation
# --------------------------------
# Content creation for various config and component files
cat << 'EOF' > ./types/index.d.ts
import type { Icon } from "lucide-react"

export type AppConfig = {
  name: string
  description: string
  url: string
}

export type Icon = Icon
EOF

cat << EOF > ./config/app.ts
import { AppConfig } from "@/types"

export const appConfig: AppConfig = {
  name: "${project_name}",
  description: "${project_description}",
  url: "https://github.com/razlevio",
}
EOF

cat << 'EOF' > ./components/providers/theme-provider.tsx
"use client"

import { ThemeProvider as NextThemesProvider } from "next-themes"
import { type ThemeProviderProps } from "next-themes/dist/types"

/**
 * ThemeProvider component wraps its children with the NextThemesProvider.
 * This provider facilitates theme switching and provides theme-related utilities.
 * 
 * @param {ThemeProviderProps} props - Props for configuring the NextThemesProvider.
 * @returns The ThemeProvider component.
 */
export function ThemeProvider({ children, ...props }: ThemeProviderProps) {
  return <NextThemesProvider {...props}>{children}</NextThemesProvider>
}
EOF

cat << 'EOF' > ./components/providers/modal-provider.tsx
"use client";

import { useEffect, useState } from "react";
import { SettingsModal } from "@/components/modals/settings-modal";

/**
 * ModalProvider component is responsible for rendering modals throughout the application.
 * It ensures that the modals are only mounted client-side to prevent issues with SSR.
 * 
 * @returns The ModalProvider component.
 */
export function ModalProvider() {
  const [isMounted, setIsMounted] = useState(false);

  // Effect to set the component as mounted after initial render.
  useEffect(() => {
    setIsMounted(true);
  }, []);

  // Render null until the component has mounted to prevent SSR hydration issues.
  if (!isMounted) return null;

  // Render the modals.
  return (
    <>
      <SettingsModal />
    </>
  );
}
EOF

cat << 'EOF' > ./components/modals/confirm-modal.tsx
"use client";

import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "@/components/ui/alert-dialog";

/**
 * Props for the ConfirmModal component.
 * @property {React.ReactNode} children - The trigger element that opens the modal.
 * @property {Function} onConfirm - The callback function to execute when the confirm action is taken.
 */
type ConfirmModalProps = {
  children: React.ReactNode;
  onConfirm: () => void;
}

/**
 * ConfirmModal component provides a user interface for confirmation actions.
 * It uses an AlertDialog to prompt the user to confirm or cancel an important action.
 *
 * @param {ConfirmModalProps} props - The props for the component.
 * @returns The ConfirmModal component.
 */
export const ConfirmModal = ({ children, onConfirm }: ConfirmModalProps) => {
  /**
   * Handles the confirm action.
   * Prevents event propagation and executes the onConfirm callback.
   *
   * @param {React.MouseEvent<HTMLButtonElement, MouseEvent>} e - The click event.
   */
  const handleConfirm = (
    e: React.MouseEvent<HTMLButtonElement, MouseEvent>
  ) => {
    e.stopPropagation();
    onConfirm();
  };

  return (
    <AlertDialog>
      {/* Trigger element to open the modal, stopping propagation to prevent unintended behavior. */}
      <AlertDialogTrigger onClick={(e) => e.stopPropagation()} asChild>
        {children}
      </AlertDialogTrigger>

      {/* Content of the modal, including header, description, and footer with actions. */}
      <AlertDialogContent>
        {/* Header section with the title and description of the confirmation. */}
        <AlertDialogHeader>
          <AlertDialogTitle>Are you absolutely sure?</AlertDialogTitle>
          <AlertDialogDescription>
            This action cannot be undone.
          </AlertDialogDescription>
        </AlertDialogHeader>

        {/* Footer section with the actions to confirm or cancel. */}
        <AlertDialogFooter>
          {/* Cancel action, also stopping propagation. */}
          <AlertDialogCancel onClick={(e) => e.stopPropagation()}>
            Cancel
          </AlertDialogCancel>
          {/* Confirm action, handled by handleConfirm. */}
          <AlertDialogAction onClick={handleConfirm}>Confirm</AlertDialogAction>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  );
};
EOF

cat << 'EOF' > ./components/modals/settings-modal.tsx
"use client"

import { Label } from "@/components/ui/label";
import { ThemeToggle } from "@/components/theme-toggle";
import { Dialog, DialogContent, DialogHeader} from "@/components/ui/dialog";
import { useSettings } from "@/hooks/use-settings";

/**
 * SettingsModal component provides a user interface for application settings.
 * It utilizes a dialog to present various setting options like theme mode toggle.
 */
export function SettingsModal() {
  // Hook to manage settings state.
  const settings = useSettings();

  return (
    // Dialog component for the modal interface.
    <Dialog open={settings.isOpen} onOpenChange={settings.onClose}>
      <DialogContent>
        {/* Header section of the dialog with the title. */}
        <DialogHeader className="border-b pb-3">
          <h2 className="text-lg font-medium">My settings</h2>
        </DialogHeader>
        {/* Content section with setting options. */}
        <div className="flex items-center justify-between">
          <div className="flex flex-col gap-y-1">
            {/* Label for the appearance settings section. */}
            <Label>
              Appearance
            </Label>
            {/* Description for the appearance settings section. */}
            <span className="">
              Customize how workspace looks on your device
            </span>
          </div>
          {/* Toggle component for changing the mode (e.g., dark/light). */}
          <ThemeToggle />
        </div>
      </DialogContent>
    </Dialog>
  )
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

export default authMiddleware({publicRoutes: ["/"]});

export const config = {
	matcher: ["/((?!.+\\.[\\w]+$|_next).*)", "/", "/(api|trpc)(.*)"],
}
EOF

cat << 'EOF' >> ./styles/globals.css
html,
body,
:root {
  height: 100%;
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

cat << 'EOF' > ./hooks/use-debounce.tsx
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

cat << 'EOF' > ./hooks/use-origin.tsx
import { useEffect, useState } from "react";

/**
 * Custom hook to retrieve the origin (protocol + hostname + port) of the current page.
 * It ensures that it only returns the origin after the component has mounted to avoid issues with server-side rendering.
 *
 * @returns {string} The origin of the current page, or an empty string if not yet mounted or if running server-side.
 */
export const useOrigin = () => {
  // State to track if the component has mounted.
  const [mounted, setMounted] = useState(false);

  // Define the origin based on the window's location if available.
  const origin =
    typeof window !== "undefined" && window.location.origin
      ? window.location.origin
      : "";

  useEffect(() => {
    // Set the component as mounted when the effect runs after initial render.
    setMounted(true);
  }, []); // Empty dependency array means this runs once after the initial render.

  // Return an empty string until the component has mounted to avoid SSR issues.
  if (!mounted) {
    return "";
  }

  // Return the origin once the component has mounted.
  return origin;
};
EOF

cat << 'EOF' > ./hooks/use-search.tsx
import { create } from "zustand";

/**
 * Type definition for the search store.
 * @typedef SearchStore
 * @property {boolean} isOpen - Boolean indicating if the search is open.
 * @property {Function} onOpen - Function to set isOpen to true.
 * @property {Function} onClose - Function to set isOpen to false.
 * @property {Function} toggle - Function to toggle the isOpen state.
 */
type SearchStore = {
  isOpen: boolean;
  onOpen: () => void;
  onClose: () => void;
  toggle: () => void;
};

/**
 * Custom hook to manage search UI state.
 * This hook utilizes Zustand, a small, fast and scalable bearbones state-management solution.
 * It provides a simple API to open, close, and toggle the search UI's visibility.
 *
 * @returns {SearchStore} The search store with isOpen state and handlers for opening, closing, and toggling.
 */
export const useSearch = create<SearchStore>((set, get) => ({ 
  // Initial state: search UI is not open.
  isOpen: false,
  // Handler to open the search UI: sets isOpen to true.
  onOpen: () => set({ isOpen: true }),
  // Handler to close the search UI: sets isOpen to false.
  onClose: () => set({ isOpen: false }),
  // Handler to toggle the search UI's visibility.
  toggle: () => set({ isOpen: !get().isOpen }),
}));
EOF

cat << 'EOF' > ./hooks/use-settings.tsx
import { create } from "zustand";

/**
 * Type definition for the settings store.
 * @typedef SettingsStore
 * @property {boolean} isOpen - Boolean indicating if the setting is open.
 * @property {Function} onOpen - Function to set isOpen to true.
 * @property {Function} onClose - Function to set isOpen to false.
 */
type SettingsStore = {
  isOpen: boolean;
  onOpen: () => void;
  onClose: () => void;
};

/**
 * Custom hook to manage settings.
 * This hook utilizes Zustand, a small, fast and scalable bearbones state-management solution.
 * @returns {SettingsStore} The settings store with isOpen state and handlers for opening and closing.
 */
export const useSettings = create<SettingsStore>((set) => ({
  // Initial state: settings are not open.
  isOpen: false,
  // Handler to open settings: sets isOpen to true.
  onOpen: () => set({ isOpen: true }),
  // Handler to close settings: sets isOpen to false.
  onClose: () => set({ isOpen: false }),
}));
EOF

if [ "$deploying_on_vercel" = "y" ]; then
cat << 'EOF' > ./app/layout.tsx
import "@/styles/globals.css"
import { Metadata } from "next"
import { appConfig } from "@/config/app"
import { geist, geistMono } from "@/lib/fonts"
import { cn } from "@/lib/utils"
import { ModalProvider } from "@/components/providers/modal-provider";
import { ThemeProvider } from "@/components/providers/theme-provider"
import { Toaster } from "sonner";
import { Analytics } from "@vercel/analytics/react"
import { SpeedInsights } from "@vercel/speed-insights/next"

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
    <html lang="en" className={cn("h-full", geist.className, geist.variable, geistMono.variable)} suppressHydrationWarning>
      <body>
        <ThemeProvider attribute="class" defaultTheme="system" enableSystem disableTransitionOnChange>
          <Toaster position="bottom-center" />
          <ModalProvider />
          {children}
          <Analytics />
          <SpeedInsights />
        </ThemeProvider>
      </body>
    </html>
  )
}
EOF
else 
cat << 'EOF' > ./app/layout.tsx
import "@/styles/globals.css"
import { Metadata } from "next"
import { appConfig } from "@/config/app"
import { geist, geistMono } from "@/lib/fonts"
import { cn } from "@/lib/utils"
import { ModalProvider } from "@/components/providers/modal-provider";
import { ThemeProvider } from "@/components/theme-provider"
import { Toaster } from "sonner";
import { Analytics } from "@vercel/analytics/react"
import { SpeedInsights } from "@vercel/speed-insights/next"

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
    <html lang="en" className={cn("h-full", geist.className, geist.variable, geistMono.variable)} suppressHydrationWarning>
      <body>
        <ThemeProvider attribute="class" defaultTheme="system" enableSystem disableTransitionOnChange>
          <Toaster position="bottom-center" />
          <ModalProvider />
          {children}
          <Analytics />
          <SpeedInsights />
        </ThemeProvider>
      </body>
    </html>
  )
}
EOF
fi

cat << 'EOF' > ./app/page.tsx
export default function RootPage() {
  return (
    <main className="p-6 mx-auto max-w-7xl sm:px-4">
      <h1 className="font-extrabold text-7xl">Hello World</h1>
      <h2 className="text-xl mt-8">- Currently the app is not protected, update middleware and auth keys accordingly</h2>
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


cat << 'EOF' > ./.env
# TODO: update the variables since they are just placeholders
# -----------------------------------------------------------------------------
# App
# -----------------------------------------------------------------------------
NEXT_PUBLIC_APP_URL=http://localhost:3000 # http://localhost:3000 in development | https://app.domain.com in production
NODE_ENV="development" # development | production

# -----------------------------------------------------------------------------
# Authentication (Clerk.js)
# -----------------------------------------------------------------------------
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_test_YWR2YW5jZWQtaGF3ay04NS5jbGVyay5hY2NvdW50cy5kZXYk
CLERK_SECRET_KEY=sk_test_DgCuddxyEm3mAhzAatT1H3glFFPSULPCSfJRVLhc83


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

cat << 'EOF' > ./.env.example
# TODO: update the variables since they are just placeholders
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

cat << 'EOF' > ./tailwind.config.ts
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

# Section 6: Git Initialization and Final Steps
# ---------------------------------------------
git add . && git commit -m "chore(project-setup): establish structure and configuration"
figlet "Happy Coding!" | lolcat
echo ""
echo "To start the project: cd $project_name -> npm run dev"
echo "To push the project to GitHub repository:"
echo ""
echo "git remote add origin git@github.com:razlevio/$project_name.git"
echo "git branch -M main"
echo "git push -u origin main"
echo ""