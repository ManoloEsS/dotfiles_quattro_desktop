import {
	BorderedLoader,
	CustomEditor,
	DynamicBorder,
	type ExtensionAPI,
	type ExtensionContext,
	getSettingsListTheme,
} from "@earendil-works/pi-coding-agent";
import {
	Container,
	matchesKey,
	type SelectItem,
	SelectList,
	SettingsList,
	type SettingItem,
	Text,
	truncateToWidth,
} from "@earendil-works/pi-tui";

type VimMode = "normal" | "insert";

class VimEditor extends CustomEditor {
	private mode: VimMode = "insert";

	constructor(
		tui: ConstructorParameters<typeof CustomEditor>[0],
		theme: ConstructorParameters<typeof CustomEditor>[1],
		keybindings: ConstructorParameters<typeof CustomEditor>[2],
		private readonly onModeChange: (mode: VimMode) => void,
	) {
		super(tui, theme, keybindings);
	}

	private setMode(mode: VimMode): void {
		if (this.mode === mode) return;
		this.mode = mode;
		this.onModeChange(mode);
	}

	handleInput(data: string): void {
		if (matchesKey(data, "escape")) {
			if (this.mode === "insert") {
				this.setMode("normal");
				this.tui.requestRender();
				return;
			}
			// Preserve Pi's interrupt behavior in normal mode.
			super.handleInput(data);
			return;
		}

		if (this.mode === "insert") {
			super.handleInput(data);
			return;
		}

		switch (data) {
			case "i":
				this.setMode("insert");
				this.tui.requestRender();
				return;
			case "h":
				super.handleInput("\x1b[D");
				return;
			case "j":
				super.handleInput("\x1b[B");
				return;
			case "k":
				super.handleInput("\x1b[A");
				return;
			case "l":
				super.handleInput("\x1b[C");
				return;
		}

		// Keep control keys working, but do not insert normal-mode characters.
		if (data.length === 1 && data.charCodeAt(0) >= 32) return;
		super.handleInput(data);
	}

	render(width: number): string[] {
		const lines = super.render(width);
		if (lines.length === 0) return lines;

		const label = this.mode === "normal" ? " NORMAL " : " INSERT ";
		if (width > label.length) {
			const last = lines.length - 1;
			lines[last] = truncateToWidth(lines[last]!, width - label.length, "") + label;
		}
		return lines;
	}
}

function requireTui(ctx: ExtensionContext): boolean {
	if (ctx.mode === "tui") return true;
	ctx.ui.notify("This pattern requires Pi's interactive TUI mode.", "warning");
	return false;
}

export default function (pi: ExtensionAPI) {
	pi.registerCommand("patterns-pick", {
		description: "Demonstrate a SelectList selection dialog",
		handler: async (_args, ctx) => {
			if (!requireTui(ctx)) return;

			const items: SelectItem[] = [
				{ value: "opt1", label: "Option 1", description: "First option" },
				{ value: "opt2", label: "Option 2", description: "Second option" },
				{ value: "opt3", label: "Option 3" },
			];

			const result = await ctx.ui.custom<string | null>((tui, theme, _kb, done) => {
				const container = new Container();
				container.addChild(new DynamicBorder((s: string) => theme.fg("accent", s)));
				container.addChild(new Text(theme.fg("accent", theme.bold("Pick an Option")), 1, 0));

				const selectList = new SelectList(items, Math.min(items.length, 10), {
					selectedPrefix: (text) => theme.fg("accent", text),
					selectedText: (text) => theme.fg("accent", text),
					description: (text) => theme.fg("muted", text),
					scrollInfo: (text) => theme.fg("dim", text),
					noMatch: (text) => theme.fg("warning", text),
				});
				selectList.onSelect = (item) => done(item.value);
				selectList.onCancel = () => done(null);
				container.addChild(selectList);
				container.addChild(new Text(theme.fg("dim", "↑↓ navigate • enter select • esc cancel"), 1, 0));
				container.addChild(new DynamicBorder((s: string) => theme.fg("accent", s)));

				return {
					render: (width) => container.render(width),
					invalidate: () => container.invalidate(),
					handleInput: (data) => {
						selectList.handleInput(data);
						tui.requestRender();
					},
				};
			});

			if (result !== null) ctx.ui.notify(`Selected: ${result}`, "info");
		},
	});

	pi.registerCommand("patterns-fetch", {
		description: "Demonstrate a cancellable fetch operation; optionally pass a URL",
		handler: async (args, ctx) => {
			if (!requireTui(ctx)) return;
			const url = args.trim() || "https://example.com";

			const result = await ctx.ui.custom<string | null>((tui, theme, _kb, done) => {
				const loader = new BorderedLoader(tui, theme, `Fetching ${url}...`);
				let finished = false;
				const finish = (value: string | null) => {
					if (finished) return;
					finished = true;
					done(value);
				};
				loader.onAbort = () => finish(null);

				fetch(url, { signal: loader.signal })
					.then(async (response) => {
						if (!response.ok) throw new Error(`${response.status} ${response.statusText}`);
						return response.text();
					})
					.then((body) => finish(body.slice(0, 100_000)))
					.catch(() => finish(null));

				return loader;
			});

			if (result === null) {
				ctx.ui.notify("Fetch cancelled or failed", "warning");
			} else {
				ctx.ui.setEditorText(result);
			}
		},
	});

	pi.registerCommand("patterns-settings", {
		description: "Demonstrate SettingsList toggles",
		handler: async (_args, ctx) => {
			if (!requireTui(ctx)) return;

			const items: SettingItem[] = [
				{ id: "verbose", label: "Verbose mode", currentValue: "off", values: ["on", "off"] },
				{ id: "color", label: "Color output", currentValue: "on", values: ["on", "off"] },
			];

			await ctx.ui.custom((_tui, theme, _kb, done) => {
				const container = new Container();
				container.addChild(new Text(theme.fg("accent", theme.bold("Pattern Settings")), 1, 1));
				const settingsList = new SettingsList(
					items,
					Math.min(items.length + 2, 15),
					getSettingsListTheme(),
					(id, newValue) => ctx.ui.notify(`${id} = ${newValue}`, "info"),
					() => done(undefined),
					{ enableSearch: true },
				);
				container.addChild(settingsList);

				return {
					render: (width) => container.render(width),
					invalidate: () => container.invalidate(),
					handleInput: (data) => settingsList.handleInput?.(data),
				};
			});
		},
	});

	pi.on("session_start", (_event, ctx) => {
		if (ctx.mode !== "tui") return;

		const setModeStatus = (mode: VimMode) => {
			ctx.ui.setStatus(
				"common-patterns",
				ctx.ui.theme.fg("accent", `● ${mode.toUpperCase()}`),
			);
		};
		setModeStatus("insert");

		// Working indicator pattern.
		ctx.ui.setWorkingIndicator({
			frames: [
				ctx.ui.theme.fg("dim", "·"),
				ctx.ui.theme.fg("muted", "•"),
				ctx.ui.theme.fg("accent", "●"),
				ctx.ui.theme.fg("muted", "•"),
			],
			intervalMs: 120,
		});

		// Widget pattern: a small reminder above the editor.
		ctx.ui.setWidget("common-patterns", (_tui, theme) => ({
			render: (width) => [
				truncateToWidth(
					theme.fg("dim", "/patterns-pick  /patterns-fetch  /patterns-settings  •  Esc/i Vim mode"),
					width,
					"",
				),
			],
			invalidate: () => {},
		}));

		// Footer pattern: retain useful context while showing extension statuses.
		ctx.ui.setFooter((tui, theme, footerData) => ({
			invalidate() {},
			render(width: number): string[] {
				const branch = footerData.getGitBranch() || "no git";
				const statuses = [...footerData.getExtensionStatuses().values()].join(" ");
				const text = `${ctx.model?.id ?? "no model"} · ${branch}${statuses ? ` · ${statuses}` : ""}`;
				return [truncateToWidth(theme.fg("dim", text), width, "")];
			},
			dispose: footerData.onBranchChange(() => tui.requestRender()),
		}));

		ctx.ui.setEditorComponent((tui, theme, keybindings) =>
			new VimEditor(tui, theme, keybindings, setModeStatus),
		);
	});

	pi.on("session_shutdown", (_event, ctx) => {
		if (ctx.mode !== "tui") return;
		ctx.ui.setStatus("common-patterns", undefined);
		ctx.ui.setWorkingIndicator();
		ctx.ui.setWidget("common-patterns", undefined);
		ctx.ui.setFooter(undefined);
		ctx.ui.setEditorComponent(undefined);
	});
}
