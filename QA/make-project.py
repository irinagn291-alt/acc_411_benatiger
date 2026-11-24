from pathlib import Path

objects = []
def add(key, isa, **fields):
    ident = f'{len(objects)+1:024X}'
    def field(value):
        if isinstance(value, (list, tuple)):
            return '(' + ', '.join(field(v) for v in value) + (',' if value else '') + ')'
        if isinstance(value, dict):
            return '{ ' + ' '.join(f'{k} = {field(v)};' for k,v in value.items()) + ' }'
        if isinstance(value, Raw):
            return value
        return '"' + str(value).replace('"', r'\"') + '"'
    objects.append((ident, key, isa, fields, field))
    return ident

class Raw(str): pass

def cfg(name, values):
    return add(name, 'XCBuildConfiguration', name=name, buildSettings=values)
def config(name, settings):
    return add(name, 'XCConfigurationList', buildConfigurations=[cfg('Debug', settings | {
        'SWIFT_ACTIVE_COMPILATION_CONDITIONS': 'DEBUG', 'SWIFT_OPTIMIZATION_LEVEL': '-Onone',
        'DEBUG_INFORMATION_FORMAT': 'dwarf',
    }), cfg('Release', settings | {'SWIFT_COMPILATION_MODE': 'wholemodule'})], defaultConfigurationIsVisible=0, defaultConfigurationName='Release')

src = [add(name, 'PBXFileReference', path=name, lastKnownFileType='sourcecode.swift', sourceTree='<group>')
       for name in ['BureauApp.swift', 'CaseBook.swift', 'Desk.swift']]
refs = [add(name, 'PBXFileReference', path='Resources/'+name, name=name, lastKnownFileType=typ, sourceTree='<group>')
        for name, typ in [('Assets.xcassets', 'folder.assetcatalog'), ('Book','folder'),
                          ('bell.wav','audio.wav'), ('click.wav','audio.wav'), ('stamp.wav','audio.wav'),
                          ('melody.wav','audio.wav'), ('ticks.wav','audio.wav')]]
app = add('LuckyTiger.app', 'PBXFileReference', explicitFileType='wrapper.application', path='LuckyTiger.app', sourceTree='BUILT_PRODUCTS_DIR')
testapp = add('LuckyTigerUITests.xctest', 'PBXFileReference', explicitFileType='wrapper.cfbundle', path='LuckyTigerUITests.xctest', sourceTree='BUILT_PRODUCTS_DIR')
testsrc = add('BureauUITests.swift', 'PBXFileReference', path='BureauUITests.swift', lastKnownFileType='sourcecode.swift', sourceTree='<group>')
product_group = add('Products', 'PBXGroup', name='Products', children=[app,testapp], sourceTree='<group>')
game_group = add('Game', 'PBXGroup', path='Game', children=src+refs, sourceTree='<group>')
test_group = add('Tests', 'PBXGroup', path='Tests', children=[testsrc], sourceTree='<group>')
main = add('Main Group', 'PBXGroup', children=[game_group,test_group,product_group], sourceTree='<group>')
def phase(name, kind, items):
    return add(name, 'PBX'+kind+'BuildPhase', buildActionMask=2147483647,
               files=[add('Build File', 'PBXBuildFile', fileRef=ref) for ref in items],
               runOnlyForDeploymentPostprocessing=0)

common = {'SDKROOT':'iphoneos','IPHONEOS_DEPLOYMENT_TARGET':'17.0','TARGETED_DEVICE_FAMILY':'1,2',
          'SWIFT_VERSION':'5.0','CODE_SIGN_STYLE':'Automatic','GENERATE_INFOPLIST_FILE':'YES'}
app_cfg = config('LuckyTiger', common | {
    'PRODUCT_BUNDLE_IDENTIFIER':'com.tigerbureau.luckytiger','PRODUCT_NAME':'LuckyTiger',
    'MARKETING_VERSION':'1.0','CURRENT_PROJECT_VERSION':'1','ASSETCATALOG_COMPILER_APPICON_NAME':'AppIcon',
    'ASSETCATALOG_COMPILER_GENERATE_ASSET_SYMBOLS':'NO',
    'INFOPLIST_FILE':'Game/Info.plist','INFOPLIST_EXPAND_BUILD_SETTINGS':'YES','INFOPLIST_KEY_CFBundleDevelopmentRegion':'en-GB',
    'INFOPLIST_KEY_CFBundleDisplayName':'Benatiger','INFOPLIST_KEY_LSApplicationCategoryType':'public.app-category.games',
    'INFOPLIST_KEY_UILaunchScreen_Generation':'YES',
    'INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone':'UIInterfaceOrientationPortrait',
    'INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad':'UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight',
})
target = add('LuckyTiger', 'PBXNativeTarget', buildConfigurationList=app_cfg, buildPhases=[
    phase('Sources','Sources',src), phase('Frameworks','Frameworks',[]), phase('Resources','Resources',refs)],
    buildRules=[], dependencies=[], name='LuckyTiger', productName='LuckyTiger', productReference=app,
    productType='com.apple.product-type.application')
test_cfg = config('LuckyTigerUITests', common | {
    'PRODUCT_BUNDLE_IDENTIFIER':'com.tigerbureau.luckytiger.uitests','PRODUCT_NAME':'LuckyTigerUITests',
    'TEST_TARGET_NAME':'LuckyTiger',
})
dep = add('App Dependency', 'PBXTargetDependency', target=target)
test = add('LuckyTigerUITests','PBXNativeTarget', buildConfigurationList=test_cfg, buildPhases=[
    phase('Test Sources','Sources',[testsrc]), phase('Test Frameworks','Frameworks',[]), phase('Test Resources','Resources',[])],
    buildRules=[], dependencies=[dep], name='LuckyTigerUITests', productName='LuckyTigerUITests',
    productReference=testapp, productType='com.apple.product-type.bundle.ui-testing')
proj_cfg = config('Project', {'CLANG_ENABLE_MODULES':'YES','DEVELOPMENT_LANGUAGE':'en-GB'})
project = add('Project','PBXProject', attributes={'LastUpgradeCheck':'2700','TargetAttributes': {test:{'TestTargetID':target}}},
              buildConfigurationList=proj_cfg, compatibilityVersion='Xcode 14.0', developmentRegion='en-GB',
              hasScannedForEncodings=0, knownRegions=['en-GB','en-US','zh-Hant','ar','Base'],
              mainGroup=main, productRefGroup=product_group, projectDirPath='', projectRoot='', targets=[target,test])
lines = ['// !$*UTF8*$!', '{', '\tarchiveVersion = 1;', '\tclasses = {};', '\tobjectVersion = 56;', '\tobjects = {']
for ident, name, isa, values, format_field in objects:
    lines.append(f'\t\t{ident} /* {name} */ = {{')
    lines.append(f'\t\t\tisa = {isa};')
    for key, value in values.items():
        lines.append(f'\t\t\t{key} = {format_field(value)};')
    lines.append('\t\t};')
lines.extend(['\t};',f'\trootObject = {project};','}', ''])
Path('LuckyTiger.xcodeproj/project.pbxproj').write_text('\n'.join(lines))
def buildable(ident, target, product):
    return f'<BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{ident}" BuildableName="{product}" BlueprintName="{target}" ReferencedContainer="container:LuckyTiger.xcodeproj"/>'
app_ref = buildable(target,'LuckyTiger','LuckyTiger.app')
test_ref = buildable(test,'LuckyTigerUITests','LuckyTigerUITests.xctest')
Path('LuckyTiger.xcodeproj/xcshareddata/xcschemes/LuckyTiger.xcscheme').write_text(f'''<?xml version="1.0" encoding="UTF-8"?>
<Scheme LastUpgradeVersion="2700" version="1.7">
  <BuildAction parallelizeBuildables="NO" buildImplicitDependencies="YES">
    <BuildActionEntries>
      <BuildActionEntry buildForTesting="YES" buildForRunning="YES" buildForProfiling="YES" buildForArchiving="YES" buildForAnalyzing="YES">{app_ref}</BuildActionEntry>
    </BuildActionEntries>
  </BuildAction>
  <TestAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.DebuggerFoundation.Launcher.LLDB" shouldUseLaunchSchemeArgsEnv="YES">
    <Testables><TestableReference skipped="NO" parallelizable="NO">{test_ref}</TestableReference></Testables>
  </TestAction>
  <LaunchAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.DebuggerFoundation.Launcher.LLDB" launchStyle="0" useCustomWorkingDirectory="NO">
    <BuildableProductRunnable runnableDebuggingMode="0">{app_ref}</BuildableProductRunnable>
  </LaunchAction>
  <ProfileAction buildConfiguration="Release"><BuildableProductRunnable runnableDebuggingMode="0">{app_ref}</BuildableProductRunnable></ProfileAction>
  <AnalyzeAction buildConfiguration="Debug"/>
  <ArchiveAction buildConfiguration="Release" revealArchiveInOrganizer="YES"/>
</Scheme>
''')
