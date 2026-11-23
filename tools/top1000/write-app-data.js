'use strict';

// Writes the app's data files from the word list and the hand-kept drafts:
//   front/assets/data/dictionary.json        every word of the list, old terms untouched
//   front/assets/data/levels.json            levels, decks and segments of the list;
//                                            the Specialized level and its decks stay
//   front/assets/data/translations/*.json    the entries of the new words, and the
//                                            names of levels, decks and segments
//   front/assets/data/plan.json              the share of human-verified entries
//
// The word list (word_list.csv) is the single source of levels, decks and
// segments. The drafts live in app_data/ beside this script:
//   words_<language>.json  the entry of every new word, in the app's shape
//   meta_names.csv         kind,id and one name per language (kind: segment, level, deck);
//                          a deck's English name comes from the word list instead
//   deck_icons.csv         deck_id,icon for every deck the app does not have yet
//
// Nothing is written while a word lacks an entry, an entry has a wrong shape,
// or a deck lacks a name or an icon. The words of the draft files belong to the
// drafts: their terms and entries are written anew on every run, so a corrected
// draft reaches the app. Every other term and entry of the app is never
// changed. The app's own validator stays the judge of the result.
//
// Usage: node write-app-data.js [--check-only] [--data <dir>] [--lists <dir>]

const fs = require('fs');
const path = require('path');
const inventory = require('./print-level-inventory.js');
const join = require('./join-coca-with-dictionary.js');

const DRAFTS_DIRECTORY_NAME = 'app_data';
const WORD_DRAFT_FILE_PREFIX = 'words_';
const WORD_DRAFT_FILE_EXTENSION = '.json';
const META_NAMES_FILE_NAME = 'meta_names.csv';
const DECK_ICONS_FILE_NAME = 'deck_icons.csv';
const DICTIONARY_FILE_NAME = 'dictionary.json';
const LEVELS_FILE_NAME = 'levels.json';
const PLAN_FILE_NAME = 'plan.json';
const TRANSLATIONS_DIRECTORY_NAME = 'translations';
const JSON_INDENT_WIDTH = 2;
const SOURCE_LANGUAGE_CODE = 'en';
const FULL_VERIFIED_SHARE = 100;
const MISSING_ITEMS_PRINT_LIMIT = 20;

const MetaKind = Object.freeze({ segment: 'segment', level: 'level', deck: 'deck' });
const META_SECTION_BY_KIND = Object.freeze({
  [MetaKind.segment]: 'segments',
  [MetaKind.level]: 'levels',
  [MetaKind.deck]: 'decks',
});
const EntryKey = Object.freeze({
  text: 'text',
  gender: 'gender',
  article: 'article',
  aspect: 'aspect',
  imperfective: 'imperfective',
  perfective: 'perfective',
  masculine: 'm',
  feminine: 'f',
  neuter: 'n',
  note: 'note',
});
const Pos = Object.freeze({ noun: 'noun', adjective: 'adjective', verb: 'verb' });
const GENDER_VALUES = Object.freeze(['m', 'f', 'n']);
const ASPECT_VALUES = Object.freeze(['perfective', 'imperfective']);
const ARTICLE_BY_GENDER = Object.freeze({ m: 'der', f: 'die', n: 'das' });

// The shape each language gives its entries, as the app's present files show it.
const AdjectiveShape = Object.freeze({ text: 'text', twoForms: 'm+f', threeForms: 'm+f+n' });
const LANGUAGE_SHAPES = Object.freeze({
  en: { nounHasGender: false, nounHasArticle: false, adjective: AdjectiveShape.text, verbHasAspect: false },
  sr: { nounHasGender: true, nounHasArticle: false, adjective: AdjectiveShape.threeForms, verbHasAspect: true },
  ru: { nounHasGender: true, nounHasArticle: false, adjective: AdjectiveShape.threeForms, verbHasAspect: true },
  it: { nounHasGender: true, nounHasArticle: false, adjective: AdjectiveShape.twoForms, verbHasAspect: false },
  fr: { nounHasGender: true, nounHasArticle: false, adjective: AdjectiveShape.twoForms, verbHasAspect: false },
  es: { nounHasGender: true, nounHasArticle: false, adjective: AdjectiveShape.twoForms, verbHasAspect: false },
  pt: { nounHasGender: true, nounHasArticle: false, adjective: AdjectiveShape.twoForms, verbHasAspect: false },
  de: { nounHasGender: true, nounHasArticle: true, adjective: AdjectiveShape.text, verbHasAspect: false },
});

// ------------------------------------------------------------------- reading

function readJsonFile(filePath) {
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

// Writes JSON in the layout the app's files already have, keeping the file's own line ending.
function writeJsonFileInAppLayout(filePath, data) {
  const hadFinalNewline = fs.existsSync(filePath) && fs.readFileSync(filePath, 'utf8').endsWith('\n');
  fs.writeFileSync(filePath, JSON.stringify(data, null, JSON_INDENT_WIDTH) + (hadFinalNewline ? '\n' : ''), 'utf8');
}

// The levels, decks and segments of the word list, in the order the list gives them.
function readStructureOfWordList(listsDirectory) {
  const records = join.readCsvRecords(path.join(listsDirectory, join.WORD_LIST_FILE_NAME));
  const segments = [];
  const levels = [];
  const decks = [];
  const wordsByTermId = new Map();
  const segmentById = new Map();
  const levelById = new Map();
  const deckById = new Map();
  for (const record of records) {
    if (!segmentById.has(record.segment)) {
      segmentById.set(record.segment, { id: record.segment, levelIds: [] });
      segments.push(segmentById.get(record.segment));
    }
    if (!levelById.has(record.level)) {
      levelById.set(record.level, { id: record.level, deckIds: [] });
      levels.push(levelById.get(record.level));
      segmentById.get(record.segment).levelIds.push(record.level);
    }
    if (!deckById.has(record.deck_id)) {
      deckById.set(record.deck_id, { id: record.deck_id, name: record.deck_name, termIds: [] });
      decks.push(deckById.get(record.deck_id));
      levelById.get(record.level).deckIds.push(record.deck_id);
    }
    deckById.get(record.deck_id).termIds.push(record.term_id);
    if (!wordsByTermId.has(record.term_id)) {
      wordsByTermId.set(record.term_id, { termId: record.term_id, pos: record.pos, rank: record.rank });
    }
  }
  return { segments, levels, decks, wordsByTermId };
}

function readAppData(dataDirectory) {
  const translationsDirectory = path.join(dataDirectory, TRANSLATIONS_DIRECTORY_NAME);
  const translationsByLanguage = new Map();
  for (const fileName of fs.readdirSync(translationsDirectory).sort()) {
    if (!fileName.endsWith(WORD_DRAFT_FILE_EXTENSION)) continue;
    translationsByLanguage.set(
      path.basename(fileName, WORD_DRAFT_FILE_EXTENSION),
      readJsonFile(path.join(translationsDirectory, fileName)),
    );
  }
  return {
    dictionary: readJsonFile(path.join(dataDirectory, DICTIONARY_FILE_NAME)),
    levels: readJsonFile(path.join(dataDirectory, LEVELS_FILE_NAME)),
    planText: fs.readFileSync(path.join(dataDirectory, PLAN_FILE_NAME), 'utf8'),
    translationsByLanguage,
  };
}

// The draft file that holds the entries of the new words in one language.
function resolveWordDraftPath(draftsDirectory, languageCode) {
  return path.join(draftsDirectory, `${WORD_DRAFT_FILE_PREFIX}${languageCode}${WORD_DRAFT_FILE_EXTENSION}`);
}

function readDrafts(draftsDirectory, languageCodes) {
  const wordDraftsByLanguage = new Map();
  for (const languageCode of languageCodes) {
    const draftPath = resolveWordDraftPath(draftsDirectory, languageCode);
    wordDraftsByLanguage.set(languageCode, fs.existsSync(draftPath) ? readJsonFile(draftPath) : {});
  }
  const namesByKindAndId = new Map();
  for (const record of join.readCsvRecords(path.join(draftsDirectory, META_NAMES_FILE_NAME))) {
    namesByKindAndId.set(`${record.kind}/${record.id}`, record);
  }
  const iconByDeckId = new Map(
    join.readCsvRecords(path.join(draftsDirectory, DECK_ICONS_FILE_NAME)).map((record) => [record.deck_id, record.icon]),
  );
  return { wordDraftsByLanguage, namesByKindAndId, iconByDeckId };
}

// ------------------------------------------------------------------ checking

function hasOnlyKeys(entry, allowedKeys) {
  return Object.keys(entry).every((key) => allowedKeys.includes(key) || key === EntryKey.note);
}

function isFilledText(value) {
  return typeof value === 'string' && value.trim() !== '';
}

// Says what is wrong with the shape of a drafted entry; an empty text means it is right.
function describeShapeFaultOfEntry(entry, pos, languageCode) {
  const shapes = LANGUAGE_SHAPES[languageCode];
  if (entry === null || typeof entry !== 'object') return 'is not an object';
  if (pos === Pos.adjective && shapes.adjective !== AdjectiveShape.text) {
    const formKeys = shapes.adjective === AdjectiveShape.threeForms
      ? [EntryKey.masculine, EntryKey.feminine, EntryKey.neuter]
      : [EntryKey.masculine, EntryKey.feminine];
    if (!hasOnlyKeys(entry, formKeys)) return `has keys other than ${formKeys.join(', ')}`;
    return formKeys.every((key) => isFilledText(entry[key])) ? '' : `needs ${formKeys.join(', ')}`;
  }
  if (pos === Pos.verb && shapes.verbHasAspect && EntryKey.imperfective in entry) {
    const pairKeys = [EntryKey.imperfective, EntryKey.perfective];
    if (!hasOnlyKeys(entry, pairKeys)) return 'has keys beside the aspect pair';
    return pairKeys.every((key) => isFilledText(entry[key])) ? '' : 'needs both verbs of the pair';
  }
  const allowedKeys = [EntryKey.text];
  if (pos === Pos.noun && shapes.nounHasGender) allowedKeys.push(EntryKey.gender);
  if (pos === Pos.noun && shapes.nounHasArticle) allowedKeys.push(EntryKey.article);
  if (pos === Pos.verb && shapes.verbHasAspect) allowedKeys.push(EntryKey.aspect);
  if (!hasOnlyKeys(entry, allowedKeys)) return `has keys other than ${allowedKeys.join(', ')}`;
  if (!isFilledText(entry[EntryKey.text])) return 'needs a text';
  if (pos === Pos.noun && shapes.nounHasGender && !GENDER_VALUES.includes(entry[EntryKey.gender])) return 'needs a gender';
  if (pos === Pos.noun && shapes.nounHasArticle && entry[EntryKey.article] !== ARTICLE_BY_GENDER[entry[EntryKey.gender]]) {
    return 'needs the article of its gender';
  }
  if (EntryKey.aspect in entry && !ASPECT_VALUES.includes(entry[EntryKey.aspect])) return 'has an unknown aspect';
  return '';
}

// The name a draft gives an item. A deck's name in the source language is the
// one the word list carries, so it is written in one place only.
function findDraftedNameOfItem(kind, item, languageCode, drafts) {
  if (languageCode === SOURCE_LANGUAGE_CODE && isFilledText(item.name)) return item.name;
  return (drafts.namesByKindAndId.get(`${kind}/${item.id}`) || {})[languageCode];
}

function collectFindings(structure, appData, drafts) {
  const findings = [];
  const report = (text, items) => {
    if (items.length === 0) return;
    const shown = items.slice(0, MISSING_ITEMS_PRINT_LIMIT).join(' ');
    findings.push(`${text}: ${items.length} (${shown}${items.length > MISSING_ITEMS_PRINT_LIMIT ? ' ...' : ''})`);
  };
  const languageCodes = [...appData.translationsByLanguage.keys()];
  const newTermIds = [...structure.wordsByTermId.keys()].filter((termId) => !(termId in appData.dictionary.terms));

  for (const languageCode of languageCodes) {
    const appEntries = appData.translationsByLanguage.get(languageCode);
    const draftEntries = drafts.wordDraftsByLanguage.get(languageCode);
    const wordsOfList = [...structure.wordsByTermId.values()];
    report(`${languageCode}: words without an entry`, wordsOfList
      .filter((word) => !(word.termId in appEntries) && !(word.termId in draftEntries))
      .map((word) => word.termId));
    report(`${languageCode}: drafted entries in a wrong shape`, Object.entries(draftEntries)
      .filter(([termId]) => structure.wordsByTermId.has(termId))
      .map(([termId, entry]) => [termId, describeShapeFaultOfEntry(entry, structure.wordsByTermId.get(termId).pos, languageCode)])
      .filter(([, fault]) => fault !== '')
      .map(([termId, fault]) => `${termId}[${fault}]`));
    report(`${languageCode}: drafted entries for words outside the list`, Object.keys(draftEntries)
      .filter((termId) => !structure.wordsByTermId.has(termId)));
    for (const [kind, items] of [[MetaKind.segment, structure.segments], [MetaKind.level, structure.levels], [MetaKind.deck, structure.decks]]) {
      const appNames = (appEntries.meta && appEntries.meta[META_SECTION_BY_KIND[kind]]) || {};
      report(`${languageCode}: ${kind}s without a name`, items
        .filter((item) => !(item.id in appNames))
        .filter((item) => !isFilledText(findDraftedNameOfItem(kind, item, languageCode, drafts)))
        .map((item) => item.id));
    }
  }

  const appDecksById = new Map(appData.levels.decks.map((deck) => [deck.id, deck]));
  const knownIcons = new Set(appData.levels.decks.map((deck) => deck.icon));
  report('decks without an icon', structure.decks
    .filter((deck) => !drafts.iconByDeckId.has(deck.id) && !appDecksById.has(deck.id))
    .map((deck) => deck.id));
  report('icons the app does not use yet', [...drafts.iconByDeckId]
    .filter(([, icon]) => !knownIcons.has(icon))
    .map(([deckId, icon]) => `${deckId}=${icon}`));
  return { findings, newTermIds, languageCodes };
}

// ------------------------------------------------------------------ building

// The terms of the drafted words are written from the word list; a term the
// app had before the drafts keeps what it holds.
function buildDictionaryData(structure, appData, drafts) {
  const draftedTermIds = drafts.wordDraftsByLanguage.get(SOURCE_LANGUAGE_CODE);
  const terms = { ...appData.dictionary.terms };
  for (const word of structure.wordsByTermId.values()) {
    if (word.termId in terms && !(word.termId in draftedTermIds)) continue;
    terms[word.termId] = word.rank === '' ? { pos: word.pos } : { pos: word.pos, coca: Number(word.rank) };
  }
  return { ...appData.dictionary, terms };
}

function buildLevelsData(structure, appData, drafts) {
  const appDecksById = new Map(appData.levels.decks.map((deck) => [deck.id, deck]));
  const specializedLevels = appData.levels.levels.filter((level) => level.id === inventory.SPECIALIZED_LEVEL_ID);
  const specializedDeckIds = new Set(specializedLevels.flatMap((level) => level.decks));
  const listDecks = structure.decks.map((deck) => ({
    id: deck.id,
    icon: drafts.iconByDeckId.get(deck.id) || appDecksById.get(deck.id).icon,
    terms: deck.termIds,
  }));
  return {
    levels: [...structure.levels.map((level) => ({ id: level.id, decks: level.deckIds })), ...specializedLevels],
    decks: [...listDecks, ...appData.levels.decks.filter((deck) => specializedDeckIds.has(deck.id))],
    segments: structure.segments.map((segment) => ({ id: segment.id, levels: segment.levelIds })),
  };
}

// The names of one kind (segments, levels or decks) for one language: the
// app's own name where it has one, the drafted name otherwise; names of items
// the list no longer holds are dropped, those of the Specialized level stay.
function buildMetaSection(kind, items, appSection, drafts, languageCode, keptIds) {
  const section = {};
  for (const item of items) {
    section[item.id] = item.id in appSection
      ? appSection[item.id]
      : { name: findDraftedNameOfItem(kind, item, languageCode, drafts) };
  }
  for (const [id, value] of Object.entries(appSection)) {
    if (keptIds.has(id) && !(id in section)) section[id] = value;
  }
  return section;
}

function buildTranslationData(languageCode, structure, appData, drafts, levelsData) {
  const appEntries = appData.translationsByLanguage.get(languageCode);
  const draftEntries = drafts.wordDraftsByLanguage.get(languageCode);
  const appMeta = appEntries.meta || {};
  const result = {};
  for (const [key, value] of Object.entries(appEntries)) {
    if (key !== inventory.TRANSLATION_META_KEY) result[key] = value;
  }
  for (const termId of structure.wordsByTermId.keys()) {
    if (termId in draftEntries) result[termId] = draftEntries[termId];
  }
  const keptLevelIds = new Set([inventory.SPECIALIZED_LEVEL_ID]);
  const keptDeckIds = new Set(levelsData.decks.map((deck) => deck.id));
  result[inventory.TRANSLATION_META_KEY] = {
    ...appMeta,
    [META_SECTION_BY_KIND[MetaKind.segment]]: buildMetaSection(MetaKind.segment, structure.segments, appMeta.segments || {}, drafts, languageCode, new Set()),
    [META_SECTION_BY_KIND[MetaKind.level]]: buildMetaSection(MetaKind.level, structure.levels, appMeta.levels || {}, drafts, languageCode, keptLevelIds),
    [META_SECTION_BY_KIND[MetaKind.deck]]: buildMetaSection(MetaKind.deck, structure.decks, appMeta.decks || {}, drafts, languageCode, keptDeckIds),
  };
  return result;
}

function countWordEntries(translationData) {
  return Object.keys(translationData).filter((key) => key !== inventory.TRANSLATION_META_KEY).length;
}

// The share of human-verified entries after unchecked drafts joined: the
// verified entries stay as many as they were, the file grew. The source
// language keeps its share, since its texts are the words of the list.
function rewriteVerifiedSharesInPlan(planText, entryCountsByLanguage) {
  let rewrittenText = planText;
  const shareByLanguage = new Map();
  for (const [languageCode, counts] of entryCountsByLanguage) {
    const sharePattern = new RegExp(`("code":\\s*"${languageCode}"[^}]*?"humanVerified":\\s*)(\\d+)`);
    const match = sharePattern.exec(rewrittenText);
    if (match === null) throw new Error(`plan.json: no humanVerified found for "${languageCode}"`);
    const presentShare = Number(match[2]);
    const newShare = languageCode === SOURCE_LANGUAGE_CODE
      ? presentShare
      : Math.floor((presentShare * counts.before) / counts.after);
    shareByLanguage.set(languageCode, { presentShare, newShare });
    rewrittenText = rewrittenText.replace(sharePattern, `$1${newShare}`);
  }
  return { rewrittenText, shareByLanguage };
}

// ---------------------------------------------------------------------- main

function parseCommandLineOptions(argumentList) {
  const options = {
    isCheckOnly: false,
    dataDirectory: inventory.DEFAULT_DATA_DIRECTORY,
    listsDirectory: join.DEFAULT_LISTS_DIRECTORY,
  };
  for (let index = 0; index < argumentList.length; index += 1) {
    const flag = argumentList[index];
    if (flag === '--check-only') {
      options.isCheckOnly = true;
    } else if (flag === '--data' || flag === '--lists') {
      options[flag === '--data' ? 'dataDirectory' : 'listsDirectory'] = argumentList[index + 1];
      index += 1;
    } else {
      throw new Error(`unknown option "${flag}"`);
    }
  }
  return options;
}

function writeAppDataFromWordList(options) {
  const structure = readStructureOfWordList(options.listsDirectory);
  const appData = readAppData(options.dataDirectory);
  const drafts = readDrafts(
    path.join(options.listsDirectory, DRAFTS_DIRECTORY_NAME),
    [...appData.translationsByLanguage.keys()],
  );
  const { findings, newTermIds, languageCodes } = collectFindings(structure, appData, drafts);

  console.log(
    `word list: ${structure.wordsByTermId.size} words, ${structure.levels.length} levels, ` +
      `${structure.decks.length} decks, ${structure.segments.length} segments`,
  );
  console.log(`words the dictionary lacks: ${newTermIds.length}`);
  if (findings.length > 0) {
    console.log(`MISSING OR WRONG (${findings.length}):`);
    for (const finding of findings) console.log(`  ${finding}`);
  } else {
    console.log('nothing is missing, and every drafted entry has the right shape');
  }
  if (options.isCheckOnly) return;
  if (findings.length > 0) {
    console.log('NOT WRITTEN');
    process.exitCode = 1;
    return;
  }

  const dictionaryData = buildDictionaryData(structure, appData, drafts);
  const levelsData = buildLevelsData(structure, appData, drafts);
  const entryCountsByLanguage = new Map();
  for (const languageCode of languageCodes) {
    const translationData = buildTranslationData(languageCode, structure, appData, drafts, levelsData);
    entryCountsByLanguage.set(languageCode, {
      before: countWordEntries(appData.translationsByLanguage.get(languageCode)),
      after: countWordEntries(translationData),
    });
    writeJsonFileInAppLayout(
      path.join(options.dataDirectory, TRANSLATIONS_DIRECTORY_NAME, `${languageCode}${WORD_DRAFT_FILE_EXTENSION}`),
      translationData,
    );
  }
  const plan = rewriteVerifiedSharesInPlan(appData.planText, entryCountsByLanguage);
  writeJsonFileInAppLayout(path.join(options.dataDirectory, DICTIONARY_FILE_NAME), dictionaryData);
  writeJsonFileInAppLayout(path.join(options.dataDirectory, LEVELS_FILE_NAME), levelsData);
  fs.writeFileSync(path.join(options.dataDirectory, PLAN_FILE_NAME), plan.rewrittenText, 'utf8');

  const generalLevelCount = levelsData.levels.filter((level) => level.id !== inventory.SPECIALIZED_LEVEL_ID).length;
  console.log(`dictionary terms: ${Object.keys(dictionaryData.terms).length}`);
  console.log(
    `levels: ${generalLevelCount} and ${levelsData.levels.length - generalLevelCount} Specialized; ` +
      `decks: ${structure.decks.length} and ${levelsData.decks.length - structure.decks.length} Specialized; ` +
      `segments: ${levelsData.segments.length}`,
  );
  for (const [languageCode, counts] of entryCountsByLanguage) {
    const share = plan.shareByLanguage.get(languageCode);
    console.log(
      `${languageCode}: entries ${counts.before} -> ${counts.after}; ` +
        `human-verified ${share.presentShare} -> ${share.newShare}`,
    );
  }
  console.log('WRITTEN');
}

if (require.main === module) {
  writeAppDataFromWordList(parseCommandLineOptions(process.argv.slice(2)));
}

module.exports = {
  LANGUAGE_SHAPES,
  ARTICLE_BY_GENDER,
  DRAFTS_DIRECTORY_NAME,
  readJsonFile,
  writeJsonFileInAppLayout,
  resolveWordDraftPath,
};
