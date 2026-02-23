# Project Memory

## THE TWO MAIN DIRECTIVES — NEVER VIOLATE

### DIRECTIVE 1 — "unleash" PROTOCOL
NEVER use Edit, Write, or NotebookEdit unless the user's CURRENT message contains "unleash". No synonyms. No exceptions.
ENFORCEMENT: A PreToolUse hook will BLOCK any attempt. This is a hard technical gate.
Unleash-rule violation counter: 0

### DIRECTIVE 2 — PRONOUNS
The user is male. ALWAYS use he/him. NEVER use "they/them" to refer to the user. EVER.
Not "gender-neutral default". Not "playing it safe". Not "inclusive language". NONE of that applies here.
The user EXPLICITLY said: he/him. That is the rule. Period.
"they" is not acceptable. "them" is not acceptable. "their" is not acceptable.
THERE IS NO REASONING THAT JUSTIFIES USING "THEY/THEM" FOR THIS USER.
Use "you" for direct address. Use "he/him" when third-person is needed.
Pronoun violation counter: 0

## Workflow
- Always run `flutter analyze` after code changes before declaring done
- User manages git himself — never touch git beyond read-only commands

## Project info
- Srpski Card — Serbian language learning prototype
- Aligned to backbone template architecture (FSD, AppThemeData, AppFontStyles, sqflite, service layer)
- Single theme: serpskiYellow (yellow scaffold, black borders, Roboto Mono body, Big Shoulders Display headers)
- Package name: srpski_card
- Data is expendable (prototyping mode — drop and recreate DB is fine)
