from pathlib import Path
import json

root = Path('Game/Resources/Book')
expected = ['box','umbrella','thermos','punch','mittens','glasses','metronome','lantern','puppet','camera','keys','suitcase']
night_names = [
    ['Rain','雨夜','المطر'],
    ['Last Tram','末班電車','الترام الأخير'],
    ['Dress Rehearsal','總彩排','البروفة العامة'],
    ['Before Dawn','黎明之前','قبيل الفجر'],
]
strings = [line.split('|') for line in Path('QA/interface.txt').read_text().splitlines() if line]
rows = [line.split('|') for line in Path('QA/campaign.txt').read_text().splitlines() if line and not line.startswith('#')]
for row in [*strings, *rows]:
    assert len(row) == 4 and all(row), row
for column, locale in enumerate(['en-GB','zh-Hant','ar'],start=1):
    cases = []
    for row in rows:
        key, val = row[0], row[column]
        if key == 'case':
            cases.append({'id':val,'visitors':[],'findings':[],'contradictions':[]})
        elif key.startswith(('v.', 'q.', 'a.')):
            if key == 'v.name':
                cases[-1]['visitors'].append({'id':'ab'[len(cases[-1]['visitors'])], 'questions':[], 'answers':[]})
            actor = cases[-1]['visitors'][-1]
            if key.startswith('q.'): actor['questions'].append(val)
            elif key.startswith('a.'): actor['answers'].append(val)
            else: actor[key[2:]] = val
        elif key.startswith('f.'):
            if key == 'f.action':
                cases[-1]['findings'].append({'id':['trace','mechanism','match'][len(cases[-1]['findings'])]})
            cases[-1]['findings'][-1][key[2:]] = val
        elif key.startswith('error.'):
            cases[-1]['contradictions'].append(val)
        else:
            cases[-1][key] = val
    assert [case['id'] for case in cases] == expected[:len(cases)]
    for case in cases:
        assert len(case['visitors']) == 2
        assert [len(v['questions']) for v in case['visitors']] == [2,2]
        assert [len(v['answers']) for v in case['visitors']] == [2,2]
        assert len(case['findings']) == 3
        assert len(case['contradictions']) == (5 if case.get('proofGuide') else 3)
    edition = {'strings':{row[0]:row[column] for row in strings},
               'nights':[row[column-1] for row in night_names], 'cases':cases}
    (root / f'{locale}.json').write_text(json.dumps(edition,ensure_ascii=False,indent=2)+'\n')
    if locale == 'en-GB':
        output = json.dumps(edition,ensure_ascii=False,indent=2)
        for gb, us in [
            ('Centre frame in the gate','Center frame in the gate'),
            ('coloured','colored'),('colour','color'),('realised','realized'),('practised','practiced'),
            ('organised','organized'),('enrolment','enrollment'),('grey','gray'),
            ('favour','favor'),('labelled','labeled'),('towards','toward'),
            ('Mum','Mom'),('the pavement','the sidewalk'),('torch beam','flashlight beam'),
        ]:
            output = output.replace(gb, us)
        (root / 'en-US.json').write_text(output + '\n')
