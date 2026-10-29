import '../data/portfolio_data.dart';
import 'content.dart';
import 'controller.dart';

/// A token in a source line.
enum Tok { plain, keyword, string, type, prop, number, comment, value, link }

class Span {
  final Tok kind;
  final String text;

  /// For [Tok.value]: the controller key a click cycles.
  final String? key;

  /// For [Tok.link]: the file a click opens.
  final SourceFile? file;

  const Span(this.kind, this.text, {this.key, this.file});
}

class SourceLine {
  final List<Span> spans;

  /// Id of the page widget this line builds (hover outlines it).
  final String? target;

  const SourceLine(this.spans, [this.target]);

  bool get isBlank => spans.isEmpty;
}

// Tiny builders so the files below read like the code they show.
Span _p(String s) => Span(Tok.plain, s);
Span _k(String s) => Span(Tok.keyword, s);
Span _t(String s) => Span(Tok.type, s);
Span _pr(String s) => Span(Tok.prop, s);
Span _s(String s) => Span(Tok.string, "'$s'");
Span _n(String s) => Span(Tok.number, s);
Span _c(String s) => Span(Tok.comment, s);
Span _link(SourceFile f) => Span(Tok.link, f.label, file: f);

/// A clickable value: quoted strings render green, the rest orange.
Span _v(IdeController c, String key) {
  final text = c.value(key);
  return Span(
    Tok.value,
    IdeController.stringKeys.contains(key) ? "'$text'" : text,
    key: key,
  );
}

SourceLine _l(List<Span> spans, [String? target]) => SourceLine(spans, target);
const _blank = SourceLine([]);

/// Breadcrumb shown above the code.
String crumbFor(SourceFile f) => switch (f) {
  SourceFile.main => 'lib › main.dart › DamolaApp › build',
  SourceFile.work => 'lib › work.dart › projects',
  SourceFile.career => 'git log --career',
  SourceFile.writing => 'lib › writing.dart › writing',
  SourceFile.afterHours => 'lib › after_hours.dart › afterHours',
  SourceFile.contact => 'contact.sh',
};

List<SourceLine> linesFor(SourceFile f, IdeController c) => switch (f) {
  SourceFile.main => _main(c),
  SourceFile.work => _work(c),
  SourceFile.career => _career(c),
  SourceFile.writing => _writing(c),
  SourceFile.afterHours => _afterHours(c),
  SourceFile.contact => _contact(),
};

List<SourceLine> _main(IdeController c) => [
  _l([_k('import '), _s('package:flutter/material.dart'), _p(';')]),
  _l([_k('import '), _p("'"), _link(SourceFile.work), _p("';")]),
  _l([_k('import '), _p("'"), _link(SourceFile.writing), _p("';")]),
  _l([_k('import '), _p("'"), _link(SourceFile.afterHours), _p("';")]),
  _blank,
  _l([
    _k('void '),
    _p('main() => runApp('),
    _k('const '),
    _t('DamolaApp'),
    _p('());'),
  ]),
  _blank,
  _l([
    _k('class '),
    _t('DamolaApp '),
    _k('extends '),
    _t('StatelessWidget'),
    _p(' {'),
  ]),
  _l([
    _p('  '),
    _k('const '),
    _t('DamolaApp'),
    _p('({'),
    _k('super'),
    _p('.key});'),
  ]),
  _blank,
  _l([_c('  @override')]),
  _l([
    _p('  '),
    _t('Widget '),
    _p('build('),
    _t('BuildContext '),
    _p('context) {'),
  ]),
  _l([_p('    '), _k('return '), _t('Engineer'), _p('(')]),
  _l([_p('      '), _pr('name'), _p(': '), _v(c, 'name'), _p(',')], 'name'),
  _l([_p('      '), _pr('role'), _p(': '), _v(c, 'role'), _p(',')], 'role'),
  _l([
    _p('      '),
    _pr('specialty'),
    _p(': '),
    _v(c, 'specialty'),
    _p(','),
  ], 'role'),
  _l([
    _p('      '),
    _pr('basedIn'),
    _p(': '),
    _v(c, 'basedIn'),
    _p(','),
  ], 'status'),
  _l([
    _p('      '),
    _pr('status'),
    _p(': '),
    _t('Status'),
    _p('.'),
    _v(c, 'status'),
    _p(','),
  ], 'status'),
  _l([
    _p('      '),
    _pr('ships'),
    _p(': ['),
    _t('Android'),
    _p(', '),
    _t('IOS'),
    _p('],'),
  ], 'platforms'),
  _l([_p('      '), _pr('web'), _p(': '), _v(c, 'web'), _p(',')], 'platforms'),
  _l([
    _p('      '),
    _pr('theme'),
    _p(': '),
    _t('AppTheme'),
    _p('.'),
    _v(c, 'theme'),
    _p(',  '),
    _c('// try me'),
  ], 'page'),
  _l([
    _p('      '),
    _pr('stats'),
    _p(': kResumeStats,  '),
    _c('// every number is on my resume'),
  ], 'stats'),
  _l([
    _p('      '),
    _pr('home'),
    _p(': '),
    _k('const '),
    _t('Portfolio'),
    _p('(),'),
  ], 'cta'),
  _l([_p('    );')]),
  _l([_p('  }')]),
  _l([_p('}')]),
];

List<SourceLine> _work(IdeController c) => [
  _l([_c('// The real apps belong to the companies I built them for.')]),
  _l([_c('// These are working versions, rebuilt from scratch on mock data.')]),
  _blank,
  _l([_k('final '), _p('projects = <'), _t('Project'), _p('>[')]),
  _l([_p('  '), _t('FieldAgentApp'), _p('(')], 'project-field'),
  _l([
    _p('    '),
    _pr('client'),
    _p(': '),
    _s('NeoCash'),
    _p(','),
  ], 'project-field'),
  _l([
    _p('    '),
    _pr('commits'),
    _p(': ('),
    _n('360'),
    _p(', of: '),
    _n('448'),
    _p('),  '),
    _c('// main contributor'),
  ], 'project-field'),
  _l([
    _p('    '),
    _pr('airplaneMode'),
    _p(': '),
    _v(c, 'airplane'),
    _p(',  '),
    _c('// try me'),
  ], 'demo-field'),
  _l([
    _p('    '),
    _pr('demo'),
    _p(': '),
    _t('Demo'),
    _p('.offlineSync,'),
  ], 'demo-field'),
  _l([_p('  ),')], 'project-field'),
  _l([_p('  '), _t('LoanApp'), _p('(')], 'project-loan'),
  _l([
    _p('    '),
    _pr('stores'),
    _p(': ['),
    _t('Store'),
    _p('.play, '),
    _t('Store'),
    _p('.appStore],'),
  ], 'project-loan'),
  _l([
    _p('    '),
    _pr('retention'),
    _p(': '),
    _n('+0.15'),
    _p(','),
  ], 'project-loan'),
  _l([
    _p('    '),
    _pr('demo'),
    _p(': '),
    _t('Demo'),
    _p('.'),
    _v(c, 'loanDemo'),
    _p(','),
  ], 'demo-loan'),
  _l([_p('  ),')], 'project-loan'),
  _l([_p('  '), _t('Ajarra'), _p('(')], 'project-ajarra'),
  _l([
    _p('    '),
    _pr('commits'),
    _p(': ('),
    _n('694'),
    _p(', of: '),
    _n('707'),
    _p('),  '),
    _c('// only mobile engineer'),
  ], 'project-ajarra'),
  _l([
    _p('    '),
    _pr('demo'),
    _p(': '),
    _t('Demo'),
    _p('.'),
    _v(c, 'ajarraDemo'),
    _p(','),
  ], 'demo-ajarra'),
  _l([_p('  ),')], 'project-ajarra'),
  _l([_p('];')]),
];

List<SourceLine> _career(IdeController c) {
  final roles = CareerData.roles;
  return [
    _l([
      _c('\$ '),
      _p('git log --career '),
      Span(
        Tok.value,
        c.flag('oneline') ? '--oneline' : '--stat',
        key: 'oneline',
      ),
      _p('  '),
      _c('# try me'),
    ], 'career'),
    _blank,
    for (var i = 0; i < roles.length; i++)
      _l([
        _n(IdeContent.hashes[i]),
        if (i == 0) ...[_p(' '), _t('(HEAD -> main)')],
        _p(' ${roles[i].title} '),
        _k('@'),
        _p(' ${roles[i].company}'),
      ], 'role-$i'),
    _l([
      _n(IdeContent.hashes.last),
      _p(' '),
      _t('(tag: v1.0)'),
      _p(' BEng Electrical & Electronics Engineering'),
    ], 'role-edu'),
    _blank,
    _l([_c('# newest first · titles and dates match LinkedIn')]),
  ];
}

List<SourceLine> _writing(IdeController c) => [
  _l([_k('final '), _p('writing = '), _t('Writing'), _p('(')]),
  _l([
    _p('  '),
    _pr('technical'),
    _p(': '),
    _t('Hashnode'),
    _p('('),
    _s('daily-flutters'),
    _p('),'),
  ], 'posts'),
  _l([
    _p('  '),
    _pr('crossPosted'),
    _p(': '),
    _t('CoderLegion'),
    _p('('),
    _s('damolanelson'),
    _p('),'),
  ], 'posts'),
  _l([
    _p('  '),
    _pr('sort'),
    _p(': '),
    _t('Sort'),
    _p('.'),
    _v(c, 'sort'),
    _p(','),
  ], 'posts'),
  _l([
    _p('  '),
    _pr('offTheClock'),
    _p(': '),
    _t('Medium'),
    _p('('),
    _s('@damola_nelson'),
    _p('),  '),
    _c('// essays, not code'),
  ], 'essays'),
  _l([_p(');')]),
];

List<SourceLine> _afterHours(IdeController c) => [
  _l([_k('final '), _p('afterHours = '), _t('AfterHours'), _p('(')]),
  _l([
    _p('  '),
    _pr('learning'),
    _p(': '),
    _t('Learning'),
    _p('.'),
    _v(c, 'learning'),
    _p(','),
  ], 'tile-learning'),
  _l([
    _p('  '),
    _pr('chess'),
    _p(': '),
    _t('ChessCom'),
    _p('('),
    _s(NowPlayingData.chessUsername),
    _p(', '),
    _pr('showLastWin'),
    _p(': '),
    _v(c, 'lastWin'),
    _p('),'),
  ], 'tile-chess'),
  _l([
    _p('  '),
    _pr('music'),
    _p(': '),
    _t('Spotify'),
    _p('('),
    _pr('playing'),
    _p(': '),
    _v(c, 'playing'),
    _p('),'),
  ], 'tile-music'),
  _l([
    _p('  '),
    _pr('club'),
    _p(': '),
    _t('Club'),
    _p('.'),
    _v(c, 'club'),
    _p(',  '),
    _c('// final'),
  ], 'tile-club'),
  _l([_p(');')]),
];

List<SourceLine> _contact() => [
  _l([_c('# say hello')]),
  _l([_k('open '), _s('mailto:${ProfileData.email}')], 'email'),
  _l([_k('open '), _s(ProfileData.githubUrl)], 'links'),
  _l([_k('open '), _s(ProfileData.linkedinUrl)], 'links'),
  _l([_k('open '), _p('resume.pdf')], 'links'),
];
