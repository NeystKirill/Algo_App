// Algo & DS — App Mockup generator.
// Rebuilds every screen of the Flutter app as real Figma frames (auto-layout,
// text, vector icons — no screenshots) and wires them into a click-through
// prototype with `reactions`, using the app's own color tokens and copy.
//
// Run via Figma Desktop: Plugins → Development → Import plugin from manifest…
// then Plugins → Development → Algo & DS — App Mockup.

const COLORS = {
  background: "#F5F6FA",
  surface: "#FFFFFF",
  surfaceVariant: "#ECEEF5",
  primary: "#3D5AFE",
  onPrimary: "#FFFFFF",
  textPrimary: "#1B1D28",
  textSecondary: "#6B6F80",
  border: "#DFE2ED",
  compare: "#FFA726",
  swap: "#EF5350",
  sorted: "#4CAF50",
  error: "#EF5350",
};

const SCREEN_W = 390;
const GAP_X = 80;
// Set to "Inter" in main() if "Roboto Mono" fails to load, so code blocks
// degrade gracefully instead of crashing the whole generation.
let MONO_FONT = "Roboto Mono";

function hex(h) {
  const n = h.replace("#", "");
  return {
    r: parseInt(n.substring(0, 2), 16) / 255,
    g: parseInt(n.substring(2, 4), 16) / 255,
    b: parseInt(n.substring(4, 6), 16) / 255,
  };
}
function solid(h) {
  return [{ type: "SOLID", color: hex(h) }];
}

// ---------- low-level builders ----------

// Creates a freestanding auto-layout frame. Safe to call before appending
// anywhere — only touches primaryAxisSizingMode / counterAxisSizingMode and
// plain resize(), never layoutSizingHorizontal/Vertical (those require the
// node to already be an auto-layout child, see appendFill()/appendFixed()).
function frame(name, opts) {
  opts = opts || {};
  const f = figma.createFrame();
  f.name = name;
  f.layoutMode = opts.direction || "VERTICAL";
  f.primaryAxisSizingMode = opts.primaryAuto === false ? "FIXED" : "AUTO";
  f.counterAxisSizingMode = opts.counterAuto === false ? "FIXED" : "AUTO";
  f.itemSpacing = opts.spacing != null ? opts.spacing : 0;
  const padAll = opts.padX != null ? opts.padX : opts.pad != null ? opts.pad : 0;
  const padV = opts.padY != null ? opts.padY : opts.pad != null ? opts.pad : 0;
  f.paddingLeft = opts.padLeft != null ? opts.padLeft : padAll;
  f.paddingRight = opts.padRight != null ? opts.padRight : padAll;
  f.paddingTop = opts.padTop != null ? opts.padTop : padV;
  f.paddingBottom = opts.padBottom != null ? opts.padBottom : padV;
  f.primaryAxisAlignItems = opts.justify || "MIN";
  f.counterAxisAlignItems = opts.align || "MIN";
  f.fills = opts.fill ? solid(opts.fill) : [];
  f.cornerRadius = opts.radius || 0;
  if (opts.border) {
    f.strokes = solid(opts.border);
    f.strokeWeight = opts.borderWidth || 1;
    f.strokeAlign = "INSIDE";
  }
  if (opts.clip != null) f.clipsContent = opts.clip;
  if (opts.width != null || opts.height != null) {
    f.resize(opts.width != null ? opts.width : f.width, opts.height != null ? opts.height : f.height);
  }
  return f;
}

// Append `child` into `parent` (both already in the tree / about to be) and
// make it stretch to the parent's width. MUST be called after appendChild —
// layoutSizingHorizontal only exists on auto-layout children.
function appendFill(parent, child) {
  parent.appendChild(child);
  child.layoutSizingHorizontal = "FILL";
  return child;
}

function text(chars, opts) {
  opts = opts || {};
  const t = figma.createText();
  t.fontName = opts.mono
    ? { family: MONO_FONT, style: "Regular" }
    : { family: "Inter", style: opts.weight || "Regular" };
  t.characters = chars;
  t.fontSize = opts.size || 14;
  t.fills = solid(opts.color || COLORS.textPrimary);
  t.textAlignHorizontal = opts.align || "LEFT";
  t.textAutoResize = "HEIGHT";
  if (opts.width) t.resize(opts.width, t.height);
  if (opts.lineHeightPct) t.lineHeight = { value: opts.lineHeightPct, unit: "PERCENT" };
  return t;
}

function vectorIcon(name, pathData, opts) {
  opts = opts || {};
  const size = opts.size || 24;
  const v = figma.createVector();
  v.name = name;
  v.vectorPaths = [{ windingRule: opts.fill ? "NONZERO" : "NONE", data: pathData }];
  v.resize(size, size);
  if (opts.fill) {
    v.fills = solid(opts.color || COLORS.textPrimary);
    v.strokes = [];
  } else {
    v.fills = [];
    v.strokes = solid(opts.color || COLORS.textPrimary);
    v.strokeWeight = opts.strokeWeight || 2;
    v.strokeCap = "ROUND";
    v.strokeJoin = "ROUND";
  }
  return v;
}

// 24x24-viewBox-equivalent icon glyphs, hand-authored as straight vector
// paths (never rotated primitives), per icon-import best practice.
const ICON = {
  chevronRight: (color) => vectorIcon("chevron_right", "M9 6 L15 12 L9 18", { color, size: 22 }),
  arrowBack: (color) => vectorIcon("arrow_back", "M15 6 L9 12 L15 18 M9 12 L19 12", { color, size: 22 }),
  arrowForward: (color) =>
    vectorIcon("arrow_forward", "M5 12 L19 12 M13 6 L19 12 L13 18", { color, size: 22 }),
  logout: (color) =>
    vectorIcon("logout", "M10 5 L5 5 L5 19 L10 19 M16 16 L20 12 L16 8 M9 12 L20 12", { color, size: 22 }),
  play: (color) => vectorIcon("play", "M7 5 L19 12 L7 19 Z", { color, size: 20, fill: true }),
  skipNext: (color) =>
    vectorIcon("skip_next", "M6 5 L15 12 L6 19 Z M17 5 L19 5 L19 19 L17 19 Z", { color, size: 20, fill: true }),
  skipPrev: (color) =>
    vectorIcon("skip_prev", "M18 5 L9 12 L18 19 Z M5 5 L7 5 L7 19 L5 19 Z", { color, size: 20, fill: true }),
};

// Small composite icons built from basic shapes grouped together (not
// rotated-primitive reconstructions of a specific vendor glyph — simplified
// generic stand-ins for gear/person/search/eye).
function iconGear(color) {
  // "Sliders" style settings glyph (two adjustable rows) — reads clearly at
  // small sizes, unlike a true gear, which needs teeth too fine to render
  // reliably from hand-authored vector primitives at 22px.
  const lines = vectorIcon("settings_lines", "M3 8 L21 8 M3 16 L21 16", {
    color,
    size: 22,
    strokeWeight: 2,
  });
  const knob1 = figma.createEllipse();
  knob1.resize(5, 5);
  knob1.x = 7;
  knob1.y = 5.5;
  knob1.fills = solid(color);
  knob1.strokes = solid(COLORS.background);
  knob1.strokeWeight = 1.5;
  const knob2 = figma.createEllipse();
  knob2.resize(5, 5);
  knob2.x = 13;
  knob2.y = 13.5;
  knob2.fills = solid(color);
  knob2.strokes = solid(COLORS.background);
  knob2.strokeWeight = 1.5;
  const g = figma.group([lines, knob1, knob2], figma.currentPage);
  g.name = "settings";
  g.resize(22, 22);
  return g;
}
function iconPerson(color) {
  const head = figma.createEllipse();
  head.resize(9, 9);
  head.x = 6.5;
  head.y = 2;
  head.fills = solid(color);
  const body = figma.createRectangle();
  body.resize(16, 10);
  body.x = 3;
  body.y = 12;
  body.cornerRadius = 8;
  body.fills = solid(color);
  const g = figma.group([head, body], figma.currentPage);
  g.name = "person";
  g.resize(22, 22);
  return g;
}
function iconSearch(color) {
  const e = figma.createEllipse();
  e.resize(13, 13);
  e.fills = [];
  e.strokes = solid(color);
  e.strokeWeight = 2;
  const handle = vectorIcon("handle", "M13 13 L19 19", { color, size: 19, strokeWeight: 2 });
  const g = figma.group([e, handle], figma.currentPage);
  g.name = "search";
  g.resize(22, 22);
  return g;
}
function iconEye(color) {
  // Symmetric lens shape: one cubic curve for the top lid, one for the
  // bottom, meeting at the two corners — simpler and more reliable than a
  // multi-segment outline, and reads clearly as an eye at 22px.
  const outline = vectorIcon("eye_outline", "M3 12 C7 5 17 5 21 12 C17 19 7 19 3 12 Z", {
    color,
    size: 22,
  });
  const pupil = figma.createEllipse();
  pupil.resize(6, 6);
  pupil.x = 9;
  pupil.y = 9;
  pupil.fills = solid(color);
  const g = figma.group([outline, pupil], figma.currentPage);
  g.name = "eye";
  g.resize(22, 22);
  return g;
}
function barsIcon(colorStrong) {
  const row = frame("bars_icon", { direction: "HORIZONTAL", spacing: 3, align: "MAX" });
  [10, 16, 13].forEach((h) => {
    const r = figma.createRectangle();
    r.resize(5, h);
    r.cornerRadius = 2.5;
    r.fills = solid(colorStrong);
    row.appendChild(r);
  });
  return row;
}
function sortBarsMotif() {
  // Mirrors the app's own AuthHeader "frozen mid-sort" brand motif.
  const heights = [26, 34, 44, 30, 38, 22, 48];
  const row = frame("sort_bars", { direction: "HORIZONTAL", spacing: 6, align: "MAX" });
  heights.forEach((h, i) => {
    const r = figma.createRectangle();
    r.resize(12, h);
    r.cornerRadius = 6;
    let color = COLORS.surfaceVariant;
    if (i < 2) color = COLORS.sorted;
    else if (i === 2) color = COLORS.swap;
    else if (i === 3) color = COLORS.compare;
    r.fills = solid(color);
    if (i === 2) {
      r.strokes = solid(COLORS.primary);
      r.strokeWeight = 2;
    }
    row.appendChild(r);
  });
  return row;
}

// ---------- composite widgets (freestanding; append then fill at call site) ----------

function field(label, placeholder, opts) {
  opts = opts || {};
  const box = frame("field", {
    direction: "HORIZONTAL",
    pad: 12,
    padLeft: 16,
    padRight: 16,
    fill: COLORS.surfaceVariant,
    radius: 12,
    border: COLORS.border,
    align: "CENTER",
    justify: "SPACE_BETWEEN",
  });
  const col = frame("field_text", { direction: "VERTICAL", spacing: 2 });
  col.appendChild(text(label, { size: 11, color: COLORS.textSecondary }));
  col.appendChild(text(placeholder, { size: 14, color: COLORS.textPrimary }));
  box.appendChild(col);
  if (opts.trailingIcon) box.appendChild(opts.trailingIcon);
  return box;
}

function button(label, opts) {
  opts = opts || {};
  const b = frame("button", {
    direction: "HORIZONTAL",
    spacing: 8,
    padY: 14,
    padX: 20,
    fill: opts.outline ? COLORS.surface : COLORS.primary,
    border: opts.outline ? COLORS.border : null,
    radius: 12,
    align: "CENTER",
    justify: "CENTER",
  });
  if (opts.icon) b.appendChild(opts.icon);
  b.appendChild(
    text(label, {
      size: 14,
      weight: "Bold",
      color: opts.outline ? COLORS.textPrimary : COLORS.onPrimary,
      align: "CENTER",
    })
  );
  return b;
}

function linkText(label) {
  return text(label, { size: 14, weight: "Medium", color: COLORS.primary, align: "CENTER" });
}

function chip(label, opts) {
  opts = opts || {};
  const c = frame("chip", {
    direction: "HORIZONTAL",
    padY: 7,
    padX: 14,
    fill: opts.selected ? COLORS.primary : COLORS.surfaceVariant,
    radius: 999,
    align: "CENTER",
  });
  c.appendChild(
    text(label, {
      size: 12,
      weight: opts.selected ? "Bold" : "Regular",
      color: opts.selected ? COLORS.onPrimary : COLORS.textPrimary,
    })
  );
  return c;
}

function appBar(title, opts) {
  opts = opts || {};
  const bar = frame("app_bar", {
    direction: "HORIZONTAL",
    spacing: 12,
    padX: 16,
    align: "CENTER",
    fill: COLORS.background,
    primaryAuto: false,
    counterAuto: false,
    width: SCREEN_W,
    height: 56,
  });
  let backIcon = null;
  if (opts.back) {
    backIcon = ICON.arrowBack(COLORS.textPrimary);
    bar.appendChild(backIcon);
  }
  appendFill(bar, text(title, { size: 20, weight: "Bold" }));
  const actionIcons = {};
  if (opts.actions) {
    for (const a of opts.actions) {
      const icon =
        a === "logout"
          ? ICON.logout(COLORS.textPrimary)
          : a === "settings"
          ? iconGear(COLORS.textPrimary)
          : a === "person"
          ? iconPerson(COLORS.textPrimary)
          : null;
      if (icon) {
        bar.appendChild(icon);
        actionIcons[a] = icon;
      }
    }
  }
  return { bar, backIcon, actionIcons };
}

function tabBar(tabs, activeIndex) {
  const wrap = frame("tab_bar_wrap", {
    direction: "VERTICAL",
    spacing: 0,
    primaryAuto: false,
    counterAuto: false,
    width: SCREEN_W,
    height: 52,
  });
  const row = frame("tab_bar", {
    direction: "HORIZONTAL",
    spacing: 22,
    padLeft: 16,
    padTop: 8,
    fill: COLORS.background,
    align: "MIN",
  });
  wrap.appendChild(row);
  const tabRefs = [];
  tabs.forEach((label, i) => {
    const active = i === activeIndex;
    const col = frame("tab", { direction: "VERTICAL", spacing: 8, align: "CENTER" });
    col.appendChild(
      text(label, {
        size: 13,
        weight: active ? "Bold" : "Medium",
        color: active ? COLORS.primary : COLORS.textSecondary,
      })
    );
    const underline = figma.createRectangle();
    underline.resize(active ? 28 : 1, 3);
    underline.cornerRadius = 2;
    underline.fills = active ? solid(COLORS.primary) : solid(COLORS.background);
    col.appendChild(underline);
    row.appendChild(col);
    tabRefs.push(col);
  });
  const divider = figma.createRectangle();
  divider.resize(SCREEN_W, 1);
  divider.fills = solid(COLORS.border);
  wrap.appendChild(divider);
  return { wrap, tabRefs };
}

function card(opts) {
  opts = opts || {};
  return frame("card", {
    direction: "VERTICAL",
    spacing: opts.spacing != null ? opts.spacing : 16,
    pad: opts.pad != null ? opts.pad : 16,
    fill: COLORS.surface,
    border: COLORS.border,
    radius: opts.radius || 16,
  });
}

function screenShell(name) {
  return frame(name, {
    direction: "VERTICAL",
    spacing: 0,
    fill: COLORS.background,
    primaryAuto: true,
    counterAuto: false,
    width: SCREEN_W,
  });
}

function bodyPad(spacing) {
  return frame("body", {
    direction: "VERTICAL",
    spacing: spacing != null ? spacing : 16,
    pad: 16,
    counterAuto: false,
  });
}

// ---------- screens ----------

function buildLogin() {
  const s = screenShell("01 — Вход");

  const inner = frame("inner", {
    direction: "VERTICAL",
    spacing: 28,
    padTop: 64,
    padBottom: 40,
    padLeft: 24,
    padRight: 24,
    align: "CENTER",
    counterAuto: false,
  });
  appendFill(s, inner);

  const brand = frame("brand", { direction: "VERTICAL", spacing: 16, align: "CENTER" });
  brand.appendChild(sortBarsMotif());
  brand.appendChild(text("Algo & DS", { size: 22, weight: "Bold", align: "CENTER" }));
  brand.appendChild(
    text("Продолжите обучение с того же места", { size: 14, color: COLORS.textSecondary, align: "CENTER" })
  );
  inner.appendChild(brand);

  const c = card({ spacing: 16 });
  appendFill(inner, c);
  c.appendChild(text("Вход", { size: 24, weight: "Bold" }));
  appendFill(c, field("Email", "you@example.com"));
  appendFill(c, field("Пароль", "••••••••••", { trailingIcon: iconEye(COLORS.textSecondary) }));
  const loginBtn = button("Войти");
  appendFill(c, loginBtn);
  const registerLink = linkText("Нет аккаунта? Зарегистрироваться");
  appendFill(c, registerLink);

  return { frame: s, loginBtn, registerLink };
}

function buildRegister() {
  const s = screenShell("02 — Регистрация");

  const topRow = frame("top_row", {
    direction: "HORIZONTAL",
    padLeft: 12,
    padTop: 8,
    primaryAuto: false,
    counterAuto: false,
    width: SCREEN_W,
    height: 44,
  });
  s.appendChild(topRow);
  const backIcon = ICON.arrowBack(COLORS.textPrimary);
  topRow.appendChild(backIcon);

  const inner = frame("inner", {
    direction: "VERTICAL",
    spacing: 24,
    padBottom: 40,
    padLeft: 24,
    padRight: 24,
    align: "CENTER",
    counterAuto: false,
  });
  appendFill(s, inner);

  const brand = frame("brand", { direction: "VERTICAL", spacing: 16, align: "CENTER" });
  brand.appendChild(sortBarsMotif());
  brand.appendChild(text("Algo & DS", { size: 22, weight: "Bold", align: "CENTER" }));
  brand.appendChild(
    text("Создайте аккаунт, чтобы сохранять прогресс", {
      size: 14,
      color: COLORS.textSecondary,
      align: "CENTER",
    })
  );
  inner.appendChild(brand);

  const c = card({ spacing: 14 });
  appendFill(inner, c);
  c.appendChild(text("Регистрация", { size: 24, weight: "Bold" }));
  appendFill(c, field("Email", "you@example.com"));
  appendFill(c, field("Пароль", "••••••••••", { trailingIcon: iconEye(COLORS.textSecondary) }));

  const checklist = frame("checklist", { direction: "VERTICAL", spacing: 6, padLeft: 4 });
  c.appendChild(checklist);
  ["Минимум 8 символов", "Строчные и заглавные буквы", "Хотя бы одна цифра", "Хотя бы один спецсимвол"].forEach(
    (label) => {
      const row = frame("check_row", { direction: "HORIZONTAL", spacing: 8, align: "CENTER" });
      checklist.appendChild(row);
      const dot = figma.createEllipse();
      dot.resize(14, 14);
      dot.fills = [];
      dot.strokes = solid(COLORS.sorted);
      dot.strokeWeight = 2;
      row.appendChild(dot);
      row.appendChild(text(label, { size: 12, color: COLORS.sorted }));
    }
  );

  appendFill(c, field("Подтвердите пароль", "••••••••••", { trailingIcon: iconEye(COLORS.textSecondary) }));

  const captcha = frame("captcha", {
    direction: "HORIZONTAL",
    spacing: 8,
    pad: 14,
    fill: COLORS.surfaceVariant,
    radius: 10,
    align: "CENTER",
    justify: "CENTER",
  });
  appendFill(c, captcha);
  const check = figma.createEllipse();
  check.resize(18, 18);
  check.fills = solid(COLORS.sorted);
  captcha.appendChild(check);
  captcha.appendChild(text("Success! Cloudflare Turnstile", { size: 12, color: COLORS.textSecondary }));

  const registerBtn = button("Зарегистрироваться");
  appendFill(c, registerBtn);
  const loginLink = linkText("Уже есть аккаунт? Войти");
  appendFill(c, loginLink);

  return { frame: s, backIcon, registerBtn, loginLink };
}

function buildProfile() {
  const s = screenShell("03 — Профиль");
  const { bar, actionIcons } = appBar("Профиль", { actions: ["logout"] });
  s.appendChild(bar);

  const body = bodyPad(28);
  body.counterAxisAlignItems = "CENTER";
  appendFill(s, body);

  const avatarWrap = frame("avatar_wrap", { direction: "VERTICAL", spacing: 16, align: "CENTER" });
  body.appendChild(avatarWrap);

  const avatar = frame("avatar", {
    direction: "VERTICAL",
    align: "CENTER",
    justify: "CENTER",
    fill: COLORS.primary,
    radius: 44,
    primaryAuto: false,
    counterAuto: false,
    width: 88,
    height: 88,
  });
  avatarWrap.appendChild(avatar);
  avatar.appendChild(text("Я", { size: 32, weight: "Bold", color: COLORS.onPrimary }));

  avatarWrap.appendChild(text("Имя пользователя", { size: 22, weight: "Bold", align: "CENTER" }));
  avatarWrap.appendChild(text("user@example.com", { size: 14, color: COLORS.textSecondary, align: "CENTER" }));

  const ctaCard = frame("cta_card", {
    direction: "HORIZONTAL",
    spacing: 14,
    pad: 18,
    fill: COLORS.primary,
    radius: 18,
    align: "CENTER",
  });
  appendFill(body, ctaCard);
  const iconBox = frame("icon_box", {
    direction: "VERTICAL",
    pad: 10,
    fill: COLORS.onPrimary,
    radius: 12,
    align: "CENTER",
    justify: "CENTER",
  });
  ctaCard.appendChild(iconBox);
  iconBox.appendChild(barsIcon(COLORS.primary));
  const ctaText = frame("cta_text", { direction: "VERTICAL", spacing: 2 });
  appendFill(ctaCard, ctaText);
  ctaText.appendChild(text("Перейти к алгоритмам", { size: 16, weight: "Bold", color: COLORS.onPrimary }));
  ctaText.appendChild(text("Визуализация алгоритмов и структур данных", { size: 13, color: COLORS.onPrimary }));
  ctaCard.appendChild(ICON.arrowForward(COLORS.onPrimary));

  const fieldsCard = card({ spacing: 16 });
  appendFill(body, fieldsCard);
  appendFill(fieldsCard, field("Отображаемое имя", "Введите имя"));
  appendFill(fieldsCard, field("Ссылка на аватар", "https://..."));
  const saveBtn = button("Сохранить");
  appendFill(fieldsCard, saveBtn);

  return { frame: s, logoutIcon: actionIcons.logout, ctaCard, saveBtn };
}

function buildHome() {
  const s = screenShell("04 — Главная");
  const { bar, actionIcons } = appBar("Algo & DS", { actions: ["person", "settings"] });
  s.appendChild(bar);

  const body = bodyPad(16);
  appendFill(s, body);

  const search = frame("search", {
    direction: "HORIZONTAL",
    spacing: 10,
    padX: 16,
    padY: 12,
    fill: COLORS.surfaceVariant,
    radius: 12,
    align: "CENTER",
  });
  appendFill(body, search);
  search.appendChild(iconSearch(COLORS.textSecondary));
  search.appendChild(text("Поиск алгоритма или темы", { size: 14, color: COLORS.textSecondary }));

  body.appendChild(text("Категории", { size: 18, weight: "Bold" }));

  const list = frame("category_list", { direction: "VERTICAL", spacing: 12 });
  appendFill(body, list);

  const categories = ["Сортировки", "Поиск", "Структуры данных", "Графы", "Деревья"];
  const categoryCards = [];
  categories.forEach((label) => {
    const row = frame("category_card", {
      direction: "HORIZONTAL",
      pad: 16,
      fill: COLORS.surface,
      border: COLORS.border,
      radius: 16,
      align: "CENTER",
      justify: "SPACE_BETWEEN",
    });
    appendFill(list, row);
    row.appendChild(text(label, { size: 16, weight: "Medium" }));
    row.appendChild(ICON.chevronRight(COLORS.textSecondary));
    categoryCards.push(row);
  });

  return {
    frame: s,
    profileIcon: actionIcons.person,
    settingsIcon: actionIcons.settings,
    sortingCard: categoryCards[0],
  };
}

function buildCategory() {
  const s = screenShell("05 — Категория: Сортировки");
  const { bar, backIcon } = appBar("Сортировки", { back: true });
  s.appendChild(bar);

  const body = bodyPad(12);
  appendFill(s, body);

  const algos = [
    ["Пузырьковая сортировка", "Легко"],
    ["Сортировка вставками", "Легко"],
    ["Быстрая сортировка", "Средне"],
    ["Сортировка слиянием", "Средне"],
  ];
  const algoCards = [];
  algos.forEach(([title, diff]) => {
    const row = frame("algo_card", {
      direction: "VERTICAL",
      spacing: 8,
      pad: 16,
      fill: COLORS.surface,
      border: COLORS.border,
      radius: 14,
    });
    appendFill(body, row);
    row.appendChild(text(title, { size: 15, weight: "Medium" }));
    row.appendChild(chip(diff));
    algoCards.push(row);
  });

  return { frame: s, backIcon, firstAlgoCard: algoCards[0] };
}

function topicShell(name, activeTabIndex) {
  const s = screenShell(name);
  const { bar, backIcon } = appBar("Пузырьковая сортировка", { back: true });
  s.appendChild(bar);
  const { wrap, tabRefs } = tabBar(["Теория", "Визуализация", "Код", "Компилятор"], activeTabIndex);
  s.appendChild(wrap);
  return { s, backIcon, tabRefs };
}

function buildTopicTheory() {
  const { s, backIcon, tabRefs } = topicShell("06 — Тема: Теория", 0);

  const body = bodyPad(20);
  appendFill(s, body);

  const theory = text(
    'Простая сортировка сравнением: алгоритм много раз проходит по массиву, сравнивает соседние элементы и меняет их местами, если они стоят в неверном порядке. За каждый проход самый большой непосредственно не отсортированный элемент "всплывает" в конец.',
    { size: 15, color: COLORS.textPrimary, lineHeightPct: 150 }
  );
  appendFill(body, theory);

  const row = frame("complexity_row", { direction: "HORIZONTAL", spacing: 12 });
  appendFill(body, row);
  [
    ["Время", "O(n²)"],
    ["Память", "O(1)"],
  ].forEach(([label, value]) => {
    const cell = frame("complexity_card", {
      direction: "VERTICAL",
      spacing: 4,
      pad: 16,
      fill: COLORS.surfaceVariant,
      radius: 14,
    });
    appendFill(row, cell);
    cell.appendChild(text(label, { size: 12, color: COLORS.textSecondary }));
    cell.appendChild(text(value, { size: 18, weight: "Bold" }));
  });

  return { frame: s, backIcon, tabRefs };
}

function buildTopicVisualization() {
  const { s, backIcon, tabRefs } = topicShell("07 — Тема: Визуализация", 1);

  const body = bodyPad(16);
  body.counterAxisAlignItems = "CENTER";
  appendFill(s, body);

  const vizCard = frame("viz_card", {
    direction: "VERTICAL",
    spacing: 4,
    pad: 20,
    fill: COLORS.surfaceVariant,
    radius: 16,
    align: "CENTER",
    justify: "CENTER",
  });
  appendFill(body, vizCard);
  const bars = frame("array_bars", { direction: "HORIZONTAL", spacing: 8, align: "MAX" });
  vizCard.appendChild(bars);
  [60, 100, 140, 80, 120, 50, 160, 90].forEach((h, i) => {
    const r = figma.createRectangle();
    r.resize(24, h);
    r.cornerRadius = 4;
    let c = COLORS.surface;
    if (i < 2) c = COLORS.sorted;
    else if (i === 3) c = COLORS.swap;
    else if (i === 4) c = COLORS.compare;
    r.fills = solid(c);
    bars.appendChild(r);
  });

  const desc = text("Сравниваем элементы 4 и 5", { size: 14, align: "CENTER" });
  appendFill(body, desc);
  body.appendChild(text("Сравнений: 12   Обменов: 4", { size: 12, color: COLORS.textSecondary }));

  const controls = frame("playback_controls", { direction: "HORIZONTAL", spacing: 20, align: "CENTER" });
  body.appendChild(controls);
  controls.appendChild(ICON.skipPrev(COLORS.textPrimary));
  const playCircle = frame("play_circle", {
    direction: "VERTICAL",
    pad: 12,
    fill: COLORS.primary,
    radius: 999,
    align: "CENTER",
    justify: "CENTER",
  });
  controls.appendChild(playCircle);
  playCircle.appendChild(ICON.play(COLORS.onPrimary));
  controls.appendChild(ICON.skipNext(COLORS.textPrimary));

  return { frame: s, backIcon, tabRefs };
}

function buildTopicCompiler() {
  const { s, backIcon, tabRefs } = topicShell("08 — Тема: Компилятор", 3);

  const body = bodyPad(12);
  appendFill(s, body);

  const langs = frame("lang_chips", { direction: "HORIZONTAL", spacing: 8 });
  body.appendChild(langs);
  langs.appendChild(chip("Dart", { selected: true }));
  langs.appendChild(chip("Python"));
  langs.appendChild(chip("JavaScript"));

  const editor = frame("code_editor", {
    direction: "VERTICAL",
    pad: 12,
    fill: COLORS.surface,
    border: COLORS.border,
    radius: 12,
    primaryAuto: false,
    counterAuto: false,
    height: 160,
  });
  appendFill(body, editor);
  const code = text(
    "void main() {\n  var arr = [5, 3, 8, 1];\n  for (var i = 0; i < arr.length; i++) {\n    // bubble sort step\n  }\n  print(arr);\n}",
    { size: 12, color: COLORS.textPrimary, mono: true }
  );
  editor.appendChild(code);

  const runBtn = button("Запустить");
  appendFill(body, runBtn);

  const output = frame("output", { direction: "VERTICAL", pad: 12, fill: COLORS.surfaceVariant, radius: 12 });
  appendFill(body, output);
  output.appendChild(text("[1, 3, 5, 8]", { size: 12, color: COLORS.textPrimary, mono: true }));

  return { frame: s, backIcon, tabRefs };
}

function buildSettings() {
  const s = screenShell("09 — Настройки");
  const { bar, backIcon } = appBar("Настройки", { back: true });
  s.appendChild(bar);

  const body = bodyPad(24);
  appendFill(s, body);

  body.appendChild(text("Тема оформления", { size: 14, weight: "Bold" }));
  const segmented = frame("segmented", { direction: "HORIZONTAL", pad: 4, fill: COLORS.surfaceVariant, radius: 12 });
  appendFill(body, segmented);
  ["Система", "Светлая", "Тёмная"].forEach((label, i) => {
    const seg = frame("segment", {
      direction: "HORIZONTAL",
      padY: 8,
      fill: i === 0 ? COLORS.surface : null,
      radius: 10,
      align: "CENTER",
      justify: "CENTER",
    });
    appendFill(segmented, seg);
    seg.appendChild(text(label, { size: 13, weight: i === 0 ? "Bold" : "Regular" }));
  });

  body.appendChild(text("Скорость анимации по умолчанию", { size: 14, weight: "Bold" }));
  const sliderTrack = frame("slider", {
    direction: "VERTICAL",
    align: "CENTER",
    counterAuto: false,
    primaryAuto: false,
    height: 24,
  });
  appendFill(body, sliderTrack);
  const track = figma.createRectangle();
  track.resize(SCREEN_W - 32, 4);
  track.cornerRadius = 2;
  track.fills = solid(COLORS.border);
  sliderTrack.appendChild(track);
  const thumb = figma.createEllipse();
  thumb.resize(18, 18);
  thumb.fills = solid(COLORS.primary);
  thumb.x = (SCREEN_W - 32) * 0.4;
  thumb.y = 3;
  sliderTrack.appendChild(thumb);
  body.appendChild(text("600 мс", { size: 12, color: COLORS.textSecondary }));

  body.appendChild(text("Язык кода по умолчанию", { size: 14, weight: "Bold" }));
  const langChips = frame("lang_chips", { direction: "HORIZONTAL", spacing: 8 });
  body.appendChild(langChips);
  langChips.appendChild(chip("dart", { selected: true }));
  langChips.appendChild(chip("python"));
  langChips.appendChild(chip("javascript"));

  return { frame: s, backIcon };
}

// ---------- prototype links ----------

function link(sourceNode, destFrame) {
  if (!sourceNode || !destFrame) return;
  sourceNode.reactions = [
    {
      trigger: { type: "ON_CLICK" },
      actions: [
        {
          type: "NODE",
          destinationId: destFrame.id,
          navigation: "NAVIGATE",
          transition: null,
          preserveScrollPosition: false,
        },
      ],
    },
  ];
}

function place(node, x, y) {
  node.x = x;
  node.y = y;
}

async function main() {
  await Promise.all([
    figma.loadFontAsync({ family: "Inter", style: "Regular" }),
    figma.loadFontAsync({ family: "Inter", style: "Medium" }),
    figma.loadFontAsync({ family: "Inter", style: "Bold" }),
  ]);
  try {
    await figma.loadFontAsync({ family: "Roboto Mono", style: "Regular" });
  } catch (e) {
    MONO_FONT = "Inter"; // fall back rather than abort the whole run
  }

  const page = figma.currentPage;

  const login = buildLogin();
  const register = buildRegister();
  const profile = buildProfile();
  const home = buildHome();
  const category = buildCategory();
  const theory = buildTopicTheory();
  const viz = buildTopicVisualization();
  const compiler = buildTopicCompiler();
  const settings = buildSettings();

  const screens = [login, register, profile, home, category, theory, viz, compiler, settings];
  for (const scr of screens) page.appendChild(scr.frame);

  const row1Y = 0;
  const row2Y = 1000;
  place(login.frame, 0, row1Y);
  place(register.frame, SCREEN_W + GAP_X, row1Y);
  place(profile.frame, 2 * (SCREEN_W + GAP_X), row1Y);
  place(home.frame, 3 * (SCREEN_W + GAP_X), row1Y);
  place(category.frame, 0, row2Y);
  place(theory.frame, SCREEN_W + GAP_X, row2Y);
  place(viz.frame, 2 * (SCREEN_W + GAP_X), row2Y);
  place(compiler.frame, 3 * (SCREEN_W + GAP_X), row2Y);
  place(settings.frame, 4 * (SCREEN_W + GAP_X), row2Y);

  // ---- prototype links (on-click navigation) ----
  link(login.loginBtn, profile.frame);
  link(login.registerLink, register.frame);

  link(register.backIcon, login.frame);
  link(register.registerBtn, profile.frame);
  link(register.loginLink, login.frame);

  link(profile.logoutIcon, login.frame);
  link(profile.ctaCard, home.frame);

  link(home.profileIcon, profile.frame);
  link(home.settingsIcon, settings.frame);
  link(home.sortingCard, category.frame);

  link(category.backIcon, home.frame);
  link(category.firstAlgoCard, theory.frame);

  link(theory.backIcon, category.frame);
  link(theory.tabRefs[1], viz.frame);
  link(theory.tabRefs[3], compiler.frame);

  link(viz.backIcon, category.frame);
  link(viz.tabRefs[0], theory.frame);
  link(viz.tabRefs[3], compiler.frame);

  link(compiler.backIcon, category.frame);
  link(compiler.tabRefs[0], theory.frame);
  link(compiler.tabRefs[1], viz.frame);

  link(settings.backIcon, home.frame);

  const allFrames = screens.map((scr) => scr.frame);
  figma.viewport.scrollAndZoomIntoView(allFrames);
  figma.currentPage.selection = allFrames;

  figma.notify("Готово: " + allFrames.length + " экранов собрано и связано прототипом.");
  figma.closePlugin();
}

main().catch((e) => {
  console.error(e);
  figma.notify("Ошибка: " + e.message, { error: true });
  figma.closePlugin();
});
