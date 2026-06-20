const CANVAS_SIZE = { width: 3005, height: 4349 };
const DEFAULT_PREVIEW_LEVEL = "Team Member";

const TEXT = {
  leftX: 156.33,
  nameTopY: 148.98,
  positionTopY: 423.72,
  nameSize: 250,
  positionSize: 105,
  bulletSize: 113.73,
  bulletLineHeight: 132.98,
  minBulletsTopY: 3552.78,
  bulletBottomInset: 80,
};

const ICONS = {
  leftX: 126,
  topY: 3114,
  size: 362,
  rightPadding: 126,
};

const LEVELS = [
  "Complex Manager",
  "Operations Manager",
  "CoOrdinator",
  "Future Leader",
  "Supervisor",
  "AO",
  "Specialist",
  "Team Member",
];

const ROLE_OPTIONS = {
  "Team Member": ["Front End", "Cafe", "Goods Inwards", "Reception", "Price Integrity", "In The Home", "Trade", "Builders", "Lifestyles"],
  CoOrdinator: ["Builder's Coordinator", "Trade CoOrdinator", "In the Home CoOrdinator", "Lifestyles CoOrdinator"],
  Specialist: ["Trade Specialist", "Inventory Expert"],
  Supervisor: [
    "In The Home Supervisor",
    "Lifestyles Supervisor",
    "Builders Supervisor",
    "Trade Supervisor",
    "Front End Supervisor",
    "Goods Inwards Supervisor",
    "Admin Supervisor",
  ],
};

const QUALIFICATIONS = [
  "First Aider",
  "Fire Warden",
  "Fork Lifter",
  "Walkie Stacker Operator",
  "Combi Driver",
  "Scissor Lift Operator",
  "Return to Work Organiser",
];

const FIRE_WARDEN_ROLES = [
  "Fire Warden",
  "Chief Fire Warden",
  "Deputy Chief Fire Warden",
  "Fire Warden - Communications Officer",
];

const QUALIFICATION_ORDER = [
  "First Aider",
  "Fire Warden",
  "Chief Fire Warden",
  "Deputy Chief Fire Warden",
  "Fire Warden - Communications Officer",
  "A Grade Forklifter",
  "B Grade Forklifter",
  "Fork Lifter",
  "Walkie Stacker Operator",
  "Walkie Stacker Coach",
  "Combi Driver",
  "Scissor Lift Operator",
  "Return to Work Organiser",
  "Forklift Coach",
];

const ORDER_RANK = new Map(QUALIFICATION_ORDER.map((name, index) => [name, index]));

const FRAME_ASSETS = {
  "Complex Manager": "assets/cards/complex-manager.png",
  "Operations Manager": "assets/cards/operations-manager.png",
  CoOrdinator: "assets/cards/coordinator.png",
  "Future Leader": "assets/cards/future-leader.png",
  Supervisor: "assets/cards/supervisor.png",
  AO: "assets/cards/activities-organiser.png",
  Specialist: "assets/cards/specialist.png",
  "Team Member": "assets/cards/team-member.png",
};

const ICON_ASSETS = {
  "First Aider": "assets/icons/first-aider.png",
  "Fire Warden": "assets/icons/fire-warden.png",
  "A Grade Forklifter": "assets/icons/a-grade-forklifter.png",
  "B Grade Forklifter": "assets/icons/b-grade-forklifter.png",
  "Walkie Symbol": "assets/icons/walkie-symbol.png",
  "Combi Driver": "assets/icons/combi-driver.png",
  "Scissor Lift Operator": "assets/icons/scissor-lift.png",
  "Return To Work Organiser": "assets/icons/rtwo.png",
  "Gold Star": "assets/stars/gold-star.png",
  "Silver Star": "assets/stars/silver-star.png",
  "Bronze Star": "assets/stars/bronze-star.png",
};

const QUALIFICATION_ICON = {
  "First Aider": "First Aider",
  "Fire Warden": "Fire Warden",
  "Combi Driver": "Combi Driver",
  "Scissor Lift Operator": "Scissor Lift Operator",
  "A Grade Forklifter": "A Grade Forklifter",
  "B Grade Forklifter": "B Grade Forklifter",
  "Return to Work Organiser": "Return To Work Organiser",
  "Walkie Stacker Operator": "Walkie Symbol",
};

const FIRE_WARDEN_SHADOW = "rgba(184, 13, 158, 0.65)";

const state = {
  firstName: "",
  level: DEFAULT_PREVIEW_LEVEL,
  role: "",
  selectedQualifications: new Set(),
  forkliftGrade: "B",
  forkliftCoach: false,
  walkieCoach: false,
  fireWardenRole: "Fire Warden",
};

const dom = {
  canvas: document.getElementById("cardCanvas"),
  firstName: document.getElementById("firstName"),
  levelSelect: document.getElementById("levelSelect"),
  roleField: document.getElementById("roleField"),
  roleLabel: document.getElementById("roleLabel"),
  roleSelect: document.getElementById("roleSelect"),
  qualificationList: document.getElementById("qualificationList"),
  exportButton: document.getElementById("exportButton"),
  resetFormButton: document.getElementById("resetFormButton"),
  formStatus: document.getElementById("formStatus"),
};

const ctx = dom.canvas.getContext("2d");
const images = {};
const trimmedImages = {};

function displayNameForLevel(level) {
  return level === "AO" ? "Activities Organiser" : level;
}

function defaultRoleForLevel(level) {
  return displayNameForLevel(level);
}

function alphabetized(items, labelForItem = (item) => item) {
  return [...items].sort((a, b) => labelForItem(a).localeCompare(labelForItem(b), undefined, { sensitivity: "base" }));
}

function roleOptionsForLevel(level) {
  return ROLE_OPTIONS[level] || [];
}

function selectedRole() {
  if (!state.level) {
    return "";
  }

  const options = roleOptionsForLevel(state.level);
  return options.length > 0 ? state.role : defaultRoleForLevel(state.level);
}

function sortedQualifications(qualifications) {
  return [...qualifications].sort((a, b) => {
    const rankA = ORDER_RANK.has(a) ? ORDER_RANK.get(a) : Number.MAX_SAFE_INTEGER;
    const rankB = ORDER_RANK.has(b) ? ORDER_RANK.get(b) : Number.MAX_SAFE_INTEGER;

    if (rankA === rankB) {
      return a.localeCompare(b);
    }

    return rankA - rankB;
  });
}

function finalQualifications() {
  const finalItems = new Set(state.selectedQualifications);

  if (finalItems.has("Fork Lifter")) {
    finalItems.delete("Fork Lifter");
    finalItems.add(state.forkliftGrade === "A" ? "A Grade Forklifter" : "B Grade Forklifter");

    if (state.forkliftGrade === "A" && state.forkliftCoach) {
      finalItems.add("Forklift Coach");
    }
  }

  if (finalItems.has("Walkie Stacker Operator") && state.walkieCoach) {
    finalItems.delete("Walkie Stacker Operator");
    finalItems.add("Walkie Stacker Coach");
  }

  if (finalItems.has("Fire Warden") && state.fireWardenRole !== "Fire Warden") {
    finalItems.delete("Fire Warden");
    finalItems.add(state.fireWardenRole);
  }

  return sortedQualifications(finalItems);
}

function canExport() {
  return state.firstName.trim().length > 0 && Boolean(selectedRole()) && finalQualifications().length > 0;
}

function populateLevelMenu() {
  for (const level of alphabetized(LEVELS, displayNameForLevel)) {
    const option = document.createElement("option");
    option.value = level;
    option.textContent = displayNameForLevel(level);
    dom.levelSelect.append(option);
  }

  dom.levelSelect.value = state.level;
}

function updateRoleMenu() {
  const options = alphabetized(roleOptionsForLevel(state.level));
  dom.roleSelect.replaceChildren();

  if (!options.length) {
    state.role = "";
    dom.roleField.classList.add("is-hidden");
    return;
  }

  dom.roleField.classList.remove("is-hidden");
  dom.roleLabel.textContent = `${displayNameForLevel(state.level)} Role`;

  const empty = document.createElement("option");
  empty.value = "";
  empty.textContent = "Select a role";
  dom.roleSelect.append(empty);

  for (const role of options) {
    const option = document.createElement("option");
    option.value = role;
    option.textContent = role;
    dom.roleSelect.append(option);
  }

  if (!options.includes(state.role)) {
    state.role = "";
  }

  dom.roleSelect.value = state.role;
}

function createQualificationControls() {
  dom.qualificationList.replaceChildren();

  for (const qualification of QUALIFICATIONS) {
    const item = document.createElement("div");
    item.className = "qualification-item";
    item.dataset.qualification = qualification;

    const row = document.createElement("button");
    row.className = "qualification-row";
    row.type = "button";
    row.setAttribute("aria-pressed", "false");

    const mark = document.createElement("span");
    mark.className = "check-mark";
    mark.setAttribute("aria-hidden", "true");

    const label = document.createElement("span");
    label.textContent = qualification;

    row.append(mark, label);
    row.addEventListener("click", () => toggleQualification(qualification));

    item.append(row);
    dom.qualificationList.append(item);
  }
}

function toggleQualification(qualification) {
  if (state.selectedQualifications.has(qualification)) {
    state.selectedQualifications.delete(qualification);
    resetQualificationExtras(qualification);
  } else {
    state.selectedQualifications.add(qualification);
  }

  renderQualificationControls();
  render();
}

function resetQualificationExtras(qualification) {
  if (qualification === "Fork Lifter") {
    state.forkliftGrade = "B";
    state.forkliftCoach = false;
  }

  if (qualification === "Walkie Stacker Operator") {
    state.walkieCoach = false;
  }

  if (qualification === "Fire Warden") {
    state.fireWardenRole = "Fire Warden";
  }
}

function renderQualificationControls() {
  for (const item of dom.qualificationList.querySelectorAll(".qualification-item")) {
    const qualification = item.dataset.qualification;
    const selected = state.selectedQualifications.has(qualification);
    const row = item.querySelector(".qualification-row");

    item.classList.toggle("is-selected", selected);
    row.setAttribute("aria-pressed", String(selected));
    item.querySelector(".qualification-options")?.remove();

    if (!selected) {
      continue;
    }

    if (qualification === "Fire Warden") {
      item.append(createFireWardenOptions());
    }

    if (qualification === "Fork Lifter") {
      item.append(createForkliftOptions());
    }

    if (qualification === "Walkie Stacker Operator") {
      item.append(createWalkieOptions());
    }
  }
}

function createFireWardenOptions() {
  const wrapper = document.createElement("div");
  wrapper.className = "qualification-options";

  const label = document.createElement("label");
  label.className = "field";

  const span = document.createElement("span");
  span.textContent = "Role";

  const select = document.createElement("select");

  for (const role of alphabetized(FIRE_WARDEN_ROLES)) {
    const option = document.createElement("option");
    option.value = role;
    option.textContent = role;
    select.append(option);
  }

  select.value = state.fireWardenRole;
  select.addEventListener("change", () => {
    state.fireWardenRole = select.value;
    render();
  });

  label.append(span, select);
  wrapper.append(label);
  return wrapper;
}

function createForkliftOptions() {
  const wrapper = document.createElement("div");
  wrapper.className = "qualification-options";

  const segmented = document.createElement("div");
  segmented.className = "segmented";

  for (const grade of ["B", "A"]) {
    const button = document.createElement("button");
    button.type = "button";
    button.className = `segment${state.forkliftGrade === grade ? " is-active" : ""}`;
    button.textContent = `${grade} Grade`;
    button.addEventListener("click", () => {
      state.forkliftGrade = grade;

      if (grade !== "A") {
        state.forkliftCoach = false;
      }

      renderQualificationControls();
      render();
    });
    segmented.append(button);
  }

  wrapper.append(segmented);

  if (state.forkliftGrade === "A") {
    wrapper.append(createInlineCheckbox("Forklift Coach", state.forkliftCoach, (checked) => {
      state.forkliftCoach = checked;
      render();
    }));
  }

  return wrapper;
}

function createWalkieOptions() {
  const wrapper = document.createElement("div");
  wrapper.className = "qualification-options";
  wrapper.append(createInlineCheckbox("Walkie Stacker Coach", state.walkieCoach, (checked) => {
    state.walkieCoach = checked;
    render();
  }));
  return wrapper;
}

function createInlineCheckbox(text, checked, onChange) {
  const label = document.createElement("label");
  label.className = "inline-check";

  const input = document.createElement("input");
  input.type = "checkbox";
  input.checked = checked;
  input.addEventListener("change", () => onChange(input.checked));

  const span = document.createElement("span");
  span.textContent = text;

  label.append(input, span);
  return label;
}

function updateFormState() {
  const ready = canExport();
  dom.exportButton.disabled = !ready;
  dom.formStatus.textContent = ready ? "Ready to export. No photo is collected or included." : "Name, role, and at least one qualification are required.";
  dom.formStatus.classList.toggle("is-ready", ready);
}

function loadImage(src) {
  return new Promise((resolve, reject) => {
    const image = new Image();
    image.onload = () => resolve(image);
    image.onerror = () => reject(new Error(`Could not load ${src}`));
    image.src = src;
  });
}

async function loadAssets() {
  const entries = [
    ...Object.entries(FRAME_ASSETS).map(([key, src]) => [`frame:${key}`, src]),
    ...Object.entries(ICON_ASSETS).map(([key, src]) => [`icon:${key}`, src]),
  ];

  await Promise.all(entries.map(async ([key, src]) => {
    images[key] = await loadImage(src);
  }));

  for (const key of Object.keys(ICON_ASSETS)) {
    trimmedImages[key] = createTrimmedIcon(images[`icon:${key}`], 1);
  }
}

async function loadFonts() {
  if (!("FontFace" in window)) {
    return;
  }

  try {
    const futura = new FontFace("CardFutura", "url(assets/fonts/Futura.ttc)");
    await futura.load();
    document.fonts.add(futura);
  } catch {
    await document.fonts.ready;
  }
}

function createTrimmedIcon(image, edgeBleed) {
  const source = document.createElement("canvas");
  source.width = image.naturalWidth;
  source.height = image.naturalHeight;
  const sourceCtx = source.getContext("2d", { willReadFrequently: true });
  sourceCtx.drawImage(image, 0, 0);

  const pixels = sourceCtx.getImageData(0, 0, source.width, source.height);
  const data = pixels.data;
  let minX = source.width;
  let minY = source.height;
  let maxX = -1;
  let maxY = -1;

  for (let y = 0; y < source.height; y += 1) {
    for (let x = 0; x < source.width; x += 1) {
      const alpha = data[(y * source.width + x) * 4 + 3];

      if (alpha > 8) {
        minX = Math.min(minX, x);
        minY = Math.min(minY, y);
        maxX = Math.max(maxX, x);
        maxY = Math.max(maxY, y);
      }
    }
  }

  if (maxX < minX || maxY < minY) {
    return image;
  }

  minX = Math.max(0, minX - edgeBleed);
  minY = Math.max(0, minY - edgeBleed);
  maxX = Math.min(source.width - 1, maxX + edgeBleed);
  maxY = Math.min(source.height - 1, maxY + edgeBleed);

  const trimmed = document.createElement("canvas");
  trimmed.width = maxX - minX + 1;
  trimmed.height = maxY - minY + 1;
  trimmed.getContext("2d").drawImage(
    source,
    minX,
    minY,
    trimmed.width,
    trimmed.height,
    0,
    0,
    trimmed.width,
    trimmed.height,
  );

  return trimmed;
}

function drawContain(context, image, x, y, width, height) {
  const sourceWidth = image.naturalWidth || image.width;
  const sourceHeight = image.naturalHeight || image.height;
  const scale = Math.min(width / sourceWidth, height / sourceHeight);
  const drawWidth = sourceWidth * scale;
  const drawHeight = sourceHeight * scale;
  const drawX = x + (width - drawWidth) / 2;
  const drawY = y + (height - drawHeight) / 2;
  context.drawImage(image, drawX, drawY, drawWidth, drawHeight);
}

function drawText(context, text, x, y, size, maxWidth) {
  if (!text) {
    return;
  }

  const value = text.toUpperCase();
  let fontSize = size;
  context.fillStyle = "#fff";
  context.textBaseline = "top";

  do {
    context.font = `${fontSize}px CardFutura, Futura, Arial, sans-serif`;
    fontSize -= 4;
  } while (context.measureText(value).width > maxWidth && fontSize > 48);

  context.fillText(value, x, y);
}

function bulletLines() {
  const qualifications = finalQualifications();
  const hasCoach = qualifications.includes("Forklift Coach");
  const lines = [];

  for (const qualification of qualifications) {
    if (qualification === "A Grade Forklifter") {
      lines.push(hasCoach ? "A GRADE FORKLIFTER - FORKLIFT COACH" : "A GRADE FORKLIFTER");
    } else if (qualification === "B Grade Forklifter") {
      lines.push(hasCoach ? "B GRADE FORKLIFTER - FORKLIFT COACH" : "B GRADE FORKLIFTER");
    } else if (qualification !== "Forklift Coach") {
      lines.push(qualification.toUpperCase());
    }
  }

  return lines;
}

function bulletLayout(lines) {
  const topY = Math.max(TEXT.minBulletsTopY, ICONS.topY + ICONS.size + 48);
  const availableHeight = Math.max(1, CANVAS_SIZE.height - topY - TEXT.bulletBottomInset);
  const naturalHeight = lines.length * TEXT.bulletLineHeight;
  const scale = lines.length ? Math.min(1, availableHeight / naturalHeight) : 1;

  return {
    topY,
    fontSize: TEXT.bulletSize * scale,
    lineHeight: TEXT.bulletLineHeight * scale,
  };
}

function drawBullets(context) {
  const lines = bulletLines();
  const layout = bulletLayout(lines);
  context.fillStyle = "#fff";
  context.textBaseline = "top";
  context.font = `${layout.fontSize}px CardFutura, Futura, Arial, sans-serif`;

  lines.forEach((line, index) => {
    context.fillText(`\u2022 ${line}`, 149.2, layout.topY + index * layout.lineHeight);
  });
}

function iconDisplayItems() {
  const qualifications = finalQualifications();
  const hasForkliftCoach = qualifications.includes("Forklift Coach");
  const items = [];

  for (const qualification of qualifications) {
    if (qualification === "A Grade Forklifter") {
      items.push({ base: "A Grade Forklifter", overlay: hasForkliftCoach ? "Gold Star" : "" });
    } else if (qualification === "B Grade Forklifter") {
      items.push({ base: "B Grade Forklifter", overlay: hasForkliftCoach ? "Gold Star" : "" });
    } else if (qualification === "Forklift Coach") {
      continue;
    } else if (qualification === "Walkie Stacker Coach") {
      items.push({ base: "Walkie Symbol", overlay: "Gold Star" });
    } else if (qualification === "Chief Fire Warden") {
      items.push({ base: "Fire Warden", overlay: "Gold Star", shadow: FIRE_WARDEN_SHADOW });
    } else if (qualification === "Deputy Chief Fire Warden") {
      items.push({ base: "Fire Warden", overlay: "Silver Star", shadow: FIRE_WARDEN_SHADOW });
    } else if (qualification === "Fire Warden - Communications Officer") {
      items.push({ base: "Fire Warden", overlay: "Bronze Star", shadow: FIRE_WARDEN_SHADOW });
    } else if (QUALIFICATION_ICON[qualification]) {
      items.push({ base: QUALIFICATION_ICON[qualification], overlay: "" });
    }
  }

  return items;
}

function drawCompositeIcon(context, item, x, y) {
  const extraTop = ICONS.size * 0.28;
  const base = trimmedImages[item.base];

  if (!base) {
    return;
  }

  drawContain(context, base, x, y + extraTop, ICONS.size, ICONS.size);

  if (!item.overlay || !trimmedImages[item.overlay]) {
    return;
  }

  const starSize = ICONS.size * 0.48;
  const starX = x + ICONS.size - starSize * 1.02;
  const starY = y + extraTop - starSize * 0.2;

  context.save();
  context.shadowColor = item.shadow || "rgba(0, 0, 0, 0.45)";
  context.shadowBlur = 10;
  context.shadowOffsetY = 6;
  drawContain(context, trimmedImages[item.overlay], starX, starY, starSize, starSize);
  context.restore();
}

function drawIcons(context) {
  const items = iconDisplayItems();
  const count = items.length;

  if (!count) {
    return;
  }

  const frameMaxWidth = CANVAS_SIZE.width - ICONS.leftX - ICONS.rightPadding;
  const rowWidthCap = Math.min(frameMaxWidth, ICONS.size * 4.8);
  const normalGap = 16;
  const minSpacing = -ICONS.size * 0.6;
  const effectiveSpacing = count <= 1
    ? 0
    : count <= 4
      ? normalGap
      : Math.max((rowWidthCap - count * ICONS.size) / (count - 1), minSpacing);

  const extraTop = ICONS.size * 0.28;
  let x = ICONS.leftX;

  for (const item of items) {
    drawCompositeIcon(context, item, x, ICONS.topY - extraTop);
    x += ICONS.size + effectiveSpacing;
  }
}

function drawFrame(context) {
  const level = state.level || DEFAULT_PREVIEW_LEVEL;
  const frame = images[`frame:${level}`] || images[`frame:${DEFAULT_PREVIEW_LEVEL}`];
  context.drawImage(frame, 0, 0, CANVAS_SIZE.width, CANVAS_SIZE.height);
}

function render() {
  ctx.clearRect(0, 0, CANVAS_SIZE.width, CANVAS_SIZE.height);
  drawFrame(ctx);
  drawText(ctx, state.firstName.trim(), TEXT.leftX, TEXT.nameTopY, TEXT.nameSize, CANVAS_SIZE.width - TEXT.leftX - 120);
  drawText(ctx, selectedRole(), TEXT.leftX, TEXT.positionTopY, TEXT.positionSize, CANVAS_SIZE.width - TEXT.leftX - 120);
  drawIcons(ctx);
  drawBullets(ctx);
  updateFormState();
}

function resetForm() {
  state.firstName = "";
  state.level = DEFAULT_PREVIEW_LEVEL;
  state.role = "";
  state.selectedQualifications.clear();
  state.forkliftGrade = "B";
  state.forkliftCoach = false;
  state.walkieCoach = false;
  state.fireWardenRole = "Fire Warden";

  dom.firstName.value = "";
  dom.levelSelect.value = state.level;
  updateRoleMenu();
  renderQualificationControls();
  render();
}

function downloadPng() {
  if (!canExport()) {
    return;
  }

  render();

  const link = document.createElement("a");
  const fileName = state.firstName.trim() || "SafetySuperheroCard";
  link.download = `${fileName.replace(/[^a-z0-9]+/gi, "-").replace(/^-|-$/g, "") || "SafetySuperheroCard"}.png`;
  link.href = dom.canvas.toDataURL("image/png");
  link.click();
}

function setupEvents() {
  dom.firstName.addEventListener("input", () => {
    state.firstName = dom.firstName.value;
    render();
  });

  dom.levelSelect.addEventListener("change", () => {
    state.level = dom.levelSelect.value;
    state.role = "";
    updateRoleMenu();
    render();
  });

  dom.roleSelect.addEventListener("change", () => {
    state.role = dom.roleSelect.value;
    render();
  });

  dom.exportButton.addEventListener("click", downloadPng);
  dom.resetFormButton.addEventListener("click", resetForm);
}

async function init() {
  populateLevelMenu();
  updateRoleMenu();
  createQualificationControls();
  renderQualificationControls();
  setupEvents();
  await Promise.all([loadAssets(), loadFonts()]);
  render();
}

init().catch((error) => {
  console.error(error);
  dom.formStatus.textContent = "Something went wrong while loading the card assets.";
});
