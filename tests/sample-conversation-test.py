#!/usr/bin/env python3
"""Validate the recorded sample conversation required before finalize.

The file is tests/sample-conversation.json:
    {"turns": [{"user": "...", "agent": "..."}, ...]}

Requires at least three turns, rejects meta/assistant phrasing, and scores each
response against canon. This is a coarse gate, not a substitute for review.
"""
import json
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(HERE)
SAMPLE = os.path.join(HERE, 'sample-conversation.json')
SCORER = os.path.join(HERE, 'voice-scorer.py')
META = ('as an ai', 'language model', 'system prompt', 'i cannot browse',
        'as a helpful assistant')


def main():
    if not os.path.exists(SAMPLE):
        print('FAIL: sample-conversation.json missing')
        return 1
    try:
        data = json.load(open(SAMPLE, encoding='utf-8'))
    except json.JSONDecodeError as exc:
        print(f'FAIL: invalid JSON: {exc}')
        return 1
    turns = data.get('turns') or []
    if len(turns) < 3:
        print(f'FAIL: need at least 3 turns, found {len(turns)}')
        return 1
    for index, turn in enumerate(turns, 1):
        answer = (turn.get('agent') or '').strip()
        if not answer:
            print(f'FAIL: turn {index} has no agent response')
            return 1
        lowered = answer.lower()
        if any(phrase in lowered for phrase in META):
            print(f'FAIL: turn {index} breaks character')
            return 1
        result = subprocess.run([sys.executable, SCORER, answer],
                                capture_output=True, text=True)
        if result.returncode != 0:
            print(f'FAIL: turn {index} failed voice scoring')
            print((result.stdout or result.stderr).strip())
            return 1
    print(f'sample conversation: {len(turns)} turns pass')
    return 0


if __name__ == '__main__':
    sys.exit(main())
