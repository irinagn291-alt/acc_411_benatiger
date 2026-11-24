from pathlib import Path
import json, math, random, struct, wave

root = Path("Game/Resources")
catalog = root / "Assets.xcassets"
(catalog / "Contents.json").write_text('{"info":{"author":"xcode","version":1}}\n')
outline = "#241817"
edge = "#b68c59"
shine = "#f4d8a1"
paper = "#e6c997"
copper = "url(#gold)"
wood = "url(#wood)"
green = "url(#green)"
steel = "url(#steel)"
red = "url(#red)"
defs = '''<defs>
<linearGradient id="gold" x1="0" y1="0" x2="1" y2="1" gradientUnits="objectBoundingBox"><stop stop-color="#efce90"/><stop offset=".44" stop-color="#bb8d50"/><stop offset="1" stop-color="#624028"/></linearGradient>
<linearGradient id="wood" x1="0" y1="0" x2="0" y2="1" gradientUnits="objectBoundingBox"><stop stop-color="#ac6350"/><stop offset=".42" stop-color="#6d3a31"/><stop offset="1" stop-color="#352021"/></linearGradient>
<linearGradient id="green" x1="0" y1="0" x2="1" y2="1" gradientUnits="objectBoundingBox"><stop stop-color="#81947c"/><stop offset=".48" stop-color="#435d4f"/><stop offset="1" stop-color="#1e2926"/></linearGradient>
<linearGradient id="steel" x1="0" y1="0" x2="1" y2="1" gradientUnits="objectBoundingBox"><stop stop-color="#fff0c5"/><stop offset=".33" stop-color="#a09a84"/><stop offset=".58" stop-color="#636c65"/><stop offset="1" stop-color="#303832"/></linearGradient>
<linearGradient id="red" x1="0" y1="0" x2="0" y2="1" gradientUnits="objectBoundingBox"><stop stop-color="#cb785f"/><stop offset=".55" stop-color="#823e3b"/><stop offset="1" stop-color="#431d25"/></linearGradient>
</defs>'''

def path(d, fill="none", stroke=outline, w=3):
    return f'<path d="{d}" fill="{fill}" stroke="{stroke}" stroke-width="{w}" stroke-linecap="round" stroke-linejoin="round"/>'
def rect(x,y,w,h,fill,stroke=outline,corner=5,sw=3):
    return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{corner}" fill="{fill}" stroke="{stroke}" stroke-width="{sw}"/>'
def ellipse(x,y,rx,ry,fill,stroke=outline,w=3):
    return f'<ellipse cx="{x}" cy="{y}" rx="{rx}" ry="{ry}" fill="{fill}" stroke="{stroke}" stroke-width="{w}"/>'
def lines(*d, stroke=edge, w=2):
    return ''.join(path(p, stroke=stroke, w=w) for p in d)
def group(content, transform):
    return f'<g transform="{transform}">{content}</g>'
def mark(x,y):
    return ellipse(x,y,14,14,"none",shine,2)+ellipse(x,y,19,19,"none",edge,1)
def cross(x,y,color=shine):
    return lines(f'M{x-5} {y-4}l10 8', f'M{x-5} {y+4}l10 -8', stroke=color)
def caption_card(x,y,d):
    return rect(x,y,73,42,paper,edge,3,2)+path(d,stroke="#704333",w=2)
def asset(name, body, size="0 0 320 210"):
    folder = catalog / (name + ".imageset")
    folder.mkdir(exist_ok=True)
    (folder / "Art.svg").write_text(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="{size}">{defs}{body}</svg>\n')
    (folder / "Contents.json").write_text(json.dumps({"images":[{"idiom":"universal","filename":"Art.svg"}],
        "info":{"author":"xcode","version":1},"properties":{"preserves-vector-representation":True}}, indent=2)+"\n")

tiger = (
    path('M78 17Q45 -5 26 20Q11 42 41 67L36 98Q41 138 66 163L74 184Q92 206 121 205Q150 206 168 184L176 163Q201 138 206 98L201 67Q231 42 216 20Q197 -5 164 17Q121 3 78 17Z',copper,shine,3)
    + path('M51 45Q33 40 39 26Q51 14 72 31ZM191 45Q209 40 203 26Q191 14 170 31Z',wood)
    + path('M121 20L111 58L121 51L131 58ZM94 24L103 53L77 37ZM148 24L139 53L165 37ZM46 63L94 79L75 61ZM196 63L148 79L167 61ZM42 90L68 96L45 110ZM200 90L174 96L197 110ZM51 120L75 122L57 140ZM191 120L167 122L185 140Z',outline,outline,1)
    + path('M73 102Q85 80 104 101Q90 110 73 102ZM169 102Q157 80 138 101Q152 110 169 102Z','#171b15',shine,2)
    + ellipse(89,98,3,5,'#d8c581','none',0)+ellipse(153,98,3,5,'#d8c581','none',0)
    + path('M121 102Q116 107 107 112L90 121Q72 131 77 152Q81 173 105 179L121 171L137 179Q161 173 165 152Q170 131 152 121L135 112Q126 107 121 102Z',copper,shine,2)
    + path('M104 125Q120 119 138 125L131 138L121 145L111 138Z',outline)
    + lines('M121 145v10l-10 9','M121 155l10 9','M94 142l-13 4','M96 151l-12 6','M148 142l13 4','M146 151l12 6',stroke='#714429')
    + ellipse(121,189,43,14,'none',edge,8)+ellipse(121,189,43,14,'none',shine,2)
)
asset("Tiger",tiger,"5 -4 230 218")

base = path('M58 112L252 104L262 133L254 171Q253 178 239 181L86 187Q65 186 62 174Z',wood)
base += path('M64 141L260 132L253 167L70 175Z',wood,edge,2)
base += lines('M72 149Q147 136 256 140','M74 153Q150 144 249 146','M76 166Q177 148 249 154',
              'M93 173Q166 159 220 163',stroke='#cc8460',w=1)
base += rect(142,143,29,22,copper,corner=4)+ellipse(157,153,3,4,outline)
lid = path('M43 99L89 60L237 55L272 102L255 123L57 132Z',wood)
lid += path('M52 98L92 66L232 61L260 100L246 111L68 120Z',wood,edge,2)
lid += path('M66 98L98 72L227 67L246 99L235 105L76 114Z','none',edge,1)
lid += ellipse(157,91,28,13,copper,edge,2)+path('M141 97q8-17 12-9l8 3 7-8 7 10',stroke='#6a402b',w=2)
hinges = rect(78,107,34,16,copper,corner=3)+rect(211,101,31,14,copper,corner=3)
hinges += ellipse(86,115,2,2,outline)+ellipse(103,115,2,2,outline)+ellipse(219,107,2,2,outline)+ellipse(234,107,2,2,outline)
shell = path('M63 107L242 96L264 115L254 147L64 158L48 134Z',wood)+path('M60 132L250 121L242 147L66 154Z',wood,edge,2)
boxBack = shell+path('M50 127L64 90L239 80L259 114L241 128L69 141Z',wood,edge,3)+hinges+mark(88,117)
boxOpen = shell+path('M53 110L56 50Q60 37 72 35L238 23Q253 23 258 41L256 104L236 112L75 128Z',wood)
boxOpen += path('M65 104L68 51L244 38L242 104L75 119Z',red,edge,3)
boxOpen += path('M74 52L235 41L233 97L83 111Z','none',edge,1)
boxOpen += path('M66 132L239 121L246 134L235 154L81 163L64 149Z','#403027',edge,2)
boxOpen += rect(164,126,64,23,copper,corner=2)+rect(177,130,31,12,steel,corner=2)
boxOpen += lines(*[f'M{x} 129v12' for x in range(178,208,4)],stroke=shine,w=1)
boxOpen += group(rect(78,113,33,17,copper,corner=2),'rotate(-18 78 112)')+rect(215,107,29,12,copper,corner=3)
boxOpen += path('M78 130l37-10 21 17-40 15Z',paper,edge,2)+lines('M93 135l22-7','M98 141l23-7',stroke='#7d5438',w=1)
boxDetail = boxOpen+path('M112 49L230 56L219 144L109 134Z',paper,edge,2)
boxDetail += lines('M122 75l90 7','M122 87l75 7','M122 101c14-16 4 12 14 10s11-22 17-10-11 17 0 16 10-11 15-9s1 10 7 8 10-15 16-4 9-3 17 0','M135 125l61 6',stroke='#6a3c32',w=2)
asset("box-front",base+lid)
asset("box-back",boxBack)
asset("box-open",boxOpen)
asset("box-detail",boxDetail)
closePin = rect(0,0,143,119,"#2b231b",edge,9,3)
closePin += path('M5 59L132 30L132 82L5 106Z',wood,edge,3)
closePin += path('M22 72L78 56L111 78L61 96Z',paper,edge,2)+lines('M41 76l38-10','M51 83l37-10',stroke='#885637',w=1)
closePin += group(rect(28,25,71,18,copper,edge,2),'rotate(-18 39 36)')
closePin += group(rect(29,45,74,18,copper,edge,2),'rotate(-18 39 56)')
closePin += ellipse(43,37,8,5,shine,edge,2)+path('M44 38l-2 16-9 5',stroke='#553c2c',w=3)
closePin += ellipse(82,26,4,4,outline,edge,1)+ellipse(88,43,4,4,outline,edge,1)
closePin += lines('M108 23l4-11m-9 7l9-7 4 10',stroke=shine,w=2)
asset("box-hinge-close",closePin,"-2 -2 147 123")

# Folding umbrella, caretaker's paired red repairs
shaft = path('M55 155L230 59q23-13 29 6q6 15-9 25q-12 4-17-6',stroke=copper,w=9)
umbrella = shaft+path('M32 167Q76 108 203 65L226 88Q150 133 46 178Z',green,edge,3)
umbrella += lines('M42 169Q99 131 212 74','M52 171Q125 142 218 82','M40 169Q134 115 203 69',stroke='#8b9270')
cuff = group(rect(157,97,25,50,red,edge,2), 'rotate(58 169 122)')
asset("umbrella-front",umbrella+cuff)
asset("umbrella-back",group(umbrella+cuff,'rotate(-9 160 105)')+mark(166,121))
openedCuff = umbrella+path('M133 108l28-20 50 27-25 27Z',red,edge,2)+lines('M151 108l29 18','M161 101l29 18',stroke=shine)
asset("umbrella-open",openedCuff+cross(172,111)+cross(183,118))
asset("umbrella-detail",openedCuff+cross(172,111)+cross(183,118)+caption_card(210,135,'M219 145h49m-47 10h11m10 0h20m-35 10h40'))

# Thermos and its engraved false base
body = path('M96 65Q96 53 115 51L204 51Q222 53 223 65L232 159Q229 174 160 177Q91 174 88 159Z',green)
body += lines('M101 68l-8 84','M109 66l-6 92','M213 68l9 85',stroke='#a3ad87')
cap = rect(106,23,107,48,copper,corner=14)+ellipse(159,31,47,12,copper,edge,2)
cap += lines(*[f'M{x} 44v19' for x in range(114,207,8)],stroke='#7a5736',w=1)
foot = ellipse(160,161,72,19,copper)+ellipse(160,160,57,12,wood,edge,2)
asset("thermos-front",body+foot+cap+rect(130,94,61,35,paper,edge,4)+lines('M141 105h39','M145 113h31','M150 120h21',stroke='#7e492f',w=1))
up = group(body+cap,'rotate(63 157 100)')
baseCup = ellipse(105,137,42,35,copper)+ellipse(105,138,34,27,green,edge,2)
asset("thermos-back",up+baseCup+lines('M91 125h26','M90 133h31','M90 143h31',stroke=edge))
thermosOpen = up+ellipse(102,135,32,24,'#1a2420',edge,3)+ellipse(66,165,31,20,copper)+ellipse(66,163,22,13,wood,edge,1)
asset("thermos-open",thermosOpen)
asset("thermos-detail",thermosOpen+caption_card(215,143,'M225 163l7-10 5 12m-11-3h8m13-9v12l11-7h-10m16 7v-12h9m-9 6h7'))

# Ticket punch and a chipped tooth
ticket = rect(81,118,160,62,paper,edge,4)+lines('M91 134h140','M91 161h140','M106 143h60','M177 143h45','M110 152h93',stroke='#986347',w=1)
punch = path('M66 121Q88 117 103 113L123 91L251 48Q265 45 269 56L264 65L152 116L266 113Q277 115 274 124L264 131L134 145L85 148Q76 148 66 141Z',steel)
punch += ellipse(127,122,21,18,steel,edge,2)+ellipse(127,122,7,7,wood,outline,2)+lines('M145 109l112-52','M153 132l108-10','M78 130h30',stroke=shine)
asset("punch-front",ticket+punch)
asset("punch-back",group(ticket,'translate(0 -20)')+group(punch,'rotate(-16 128 122)')+mark(82,138))
punchOpen = ticket+group(punch,'rotate(-4 128 122)')+path('M107 168h8v-5l5-5 6 5v5h8',stroke='#402820',w=4)
asset("punch-open",punchOpen)
asset("punch-detail",punchOpen+caption_card(202,25,'M212 53h7v-6l6-5 6 5v6h20'))

# Wool mittens and a blue cross-darn that mates
mitten = path('M115 188L111 149L83 120Q73 106 83 95Q94 86 112 112L108 54Q108 37 123 30Q139 18 157 29Q173 34 177 59L176 137L168 187Z',red,edge,3)
mitten += rect(111,159,61,29,wood,edge,4)+lines(*[f'M{x} 164v19' for x in range(114,171,7)],stroke=edge,w=1)
mitten += lines('M118 54q4-18 20-19','M120 61v59','M128 57v64','M136 53v65','M145 52v69','M154 52v70','M162 55v70',stroke='#e59a76',w=1)
left = group(mitten,'rotate(-23 132 115)')
right = group(mitten,'translate(319 0) scale(-1 1) rotate(-23 132 115)')
asset("mittens-front",left+right)
asset("mittens-back",group(mitten,'translate(-40 7)')+group(mitten,'translate(368 7) scale(-1 1)')+mark(92,118)+mark(235,118))
darn = rect(111,99,42,25,green,edge,1,2)+cross(119,112,'#a8bac2')+cross(131,112,'#a8bac2')+cross(144,112,'#a8bac2')
asset("mittens-open",group(mitten+darn,'translate(-9 0)')+group(mitten+darn,'translate(329 0) scale(-1 1)'))
asset("mittens-detail",group(mitten+darn,'translate(-6 0)')+group(mitten+darn,'translate(326 0) scale(-1 1)')+mark(144,111)+mark(180,111))

# Spectacle case, impression under the fabric liner
case = rect(43,67,234,92,wood,edge,40)+rect(51,74,218,75,red,edge,35,2)+lines('M79 142q80 20 163-6','M85 86q73-17 143-1',stroke=shine,w=1)
asset("glasses-front",case+rect(147,137,26,14,copper,corner=2))
asset("glasses-back",group(case,'rotate(-12 160 105)')+mark(81,105))
imprint = ellipse(111,118,38,27,'none','#8f7768',4)+ellipse(207,118,38,27,'none','#8f7768',4)+lines('M149 114q10-11 20 0',stroke='#8f7768',w=4)
lining = rect(42,41,237,130,wood,edge,29)+rect(53,52,215,107,green,edge,24)+path('M55 87L259 77L267 126L60 139Z',red,edge,2)+imprint
asset("glasses-open",lining)
frames = ellipse(111,118,38,27,'none',copper,6)+ellipse(207,118,38,27,'none',copper,6)+lines('M149 114q10-11 20 0 M73 116l-12-6 M245 116l14-8',stroke=shine,w=3)
asset("glasses-detail",lining+frames+mark(238,103))

# Metronome with a fourth beat delayed by a pendulum stop
metBase = path('M91 160L127 25L186 25L231 160L240 177L226 190L95 190L80 177Z',wood,edge)
metBase += lines('M94 171h134','M95 180h130','M137 31l-37 128','M179 32l36 126',stroke=edge)
dial = path('M137 42h40l25 117h-91Z',green,edge,2)+lines(*[f'M146 {y}h20' for y in range(51,141,9)],stroke='#b8ac75',w=1)
arm = lines('M153 155L182 51',stroke=shine,w=3)+group(rect(157,87,21,17,copper,corner=2),'rotate(16 168 96)')
asset("metronome-front",metBase+dial+arm)
asset("metronome-back",metBase+rect(126,65,64,79,wood,edge,3)+mark(173,113))
asset("metronome-open",metBase+dial+group(arm,'rotate(19 153 155)')+mark(181,91))
asset("metronome-detail",metBase+dial+group(arm,'rotate(19 153 155)')+caption_card(211,109,'M219 122h13m4 0h10m4 0h10m-41 11h7m7 0h6m12 0h12'))

# Signal lantern, rotating its coloured shutter exposes raw blue light
lantern = rect(105,61,109,114,wood,edge,14)+ellipse(159,97,48,46,steel,edge,3)
lantern += path('M101 171h117l11 15H90Z',copper)+path('M97 72l19-33h86l19 33Z',copper)
lantern += path('M130 39q0-32 30-32q31 2 32 32',stroke=edge,w=7)
lantern += lines('M116 68h88','M111 177h99','M109 128v29','M211 128v29',stroke=shine,w=1)
asset("lantern-front",lantern+ellipse(160,106,37,39,'#a46b39',edge,4)+ellipse(160,106,24,27,'#deaa59',edge,1))
asset("lantern-back",lantern+ellipse(160,107,37,39,green,edge,5)+lines('M159 74v69','M131 109h58',stroke=shine)+mark(202,109))
blue = ellipse(160,106,37,39,'#40657a',edge,5)+path('M158 77h8v57h-8Z','#94b7be','none',0)
asset("lantern-open",lantern+blue)
asset("lantern-detail",lantern+blue+path('M182 86L259 70l-1 66-76-15Z','#698fa1','none',0)+rect(252,73,13,62,copper,corner=2))

# Hand-built marionette, different wrist joints on its replacement hands
puppet = ellipse(157,52,29,27,paper,edge,3)+path('M131 43q3-32 29-22q24 3 24 23l-22-9-13 11-16-1Z',wood)
puppet += path('M125 91l19-15h29l19 13-15 45h-35Z',red,edge)
puppet += path('M139 132l-15 40 16 11 18-37 13 40 17-8-11-46Z',wood,edge)
puppet += lines('M129 96L95 112L81 92','M188 96l39 18 14-17',stroke=edge,w=12)
puppet += ellipse(93,111,7,7,copper)+ellipse(226,112,7,7,copper)
puppet += lines('M148 54h3','M167 54h3','M151 62q5 5 10 0',stroke='#4f3330')
puppet += path('M121 6l78 7-3 7-78-8Z',wood,edge,2)+lines('M128 13l-45 76','M191 18l49 78','M156 18v10',stroke=shine,w=1)
asset("puppet-front",puppet+ellipse(79,91,9,11,paper)+ellipse(241,91,9,11,paper))
asset("puppet-back",group(puppet,'rotate(-13 158 100)')+mark(226,91))
join = ellipse(72,90,16,12,paper)+ellipse(253,88,16,12,paper)+lines('M68 86h12m-12 8h6','M247 83v11m8-10h6',stroke='#713b38',w=3)
asset("puppet-open",puppet+join)
asset("puppet-detail",puppet+join+caption_card(215,136,'M227 165h12v-17h13v8h12v9h13'))

# Bellows camera with the scratched film gate
camera = rect(49,58,224,112,wood,edge,10)+rect(50,76,222,61,green,edge,6)+rect(77,39,59,24,copper,corner=4)+rect(84,44,23,15,steel,corner=2)
camera += ellipse(156,110,54,52,wood,edge,3)+ellipse(156,110,44,43,copper)+ellipse(156,110,35,35,'#253833',edge,3)+ellipse(156,110,24,24,'#191c22','#51706b',2)+ellipse(148,103,9,8,'#73998e','none',0)
camera += lines('M63 67h204','M61 151h196',stroke=shine,w=1)
asset("camera-front",camera)
camBack = rect(45,47,229,115,wood,edge,12)+rect(56,56,209,98,'#363a32',edge,6)+rect(96,68,128,74,steel,edge,4)+rect(124,82,69,43,'#272727',edge,2)
camBack += path('M182 89l31 30-10-5 7 11',stroke=shine,w=2)
asset("camera-back",camBack+mark(196,105))
asset("camera-open",camBack+path('M65 52L26 25L30 138L61 146Z',wood,edge,3)+mark(196,105))
frame = caption_card(214,150,'M226 161l12 13-3-5 13 6')+path('M228 175l13-8 12 11 15-18 10 9',stroke='#8a7458',w=1)
asset("camera-detail",camBack+path('M65 52L26 25L30 138L61 146Z',wood,edge,3)+frame)

# Ring of warded keys, four individual profiles
def key(dx,dy,angle,teeth):
    return group(ellipse(56,33,18,15,copper)+ellipse(56,33,8,6,'#45362c')+path('M50 46h11v43'+teeth+'H50Z',copper)+lines('M54 50v47',stroke=shine,w=1),
                 f'translate({dx} {dy}) rotate({angle} 56 33)')
keys = (key(74,22,28,'h15v10H60v14H50')+key(97,23,2,'h20v7h-7v11H60v6H50')+
        key(121,22,-18,'h11v13H62v11H50')+key(142,20,-42,'h14v8h-7v9h10v7H50'))
ring = ellipse(161,54,47,23,'none',steel,9)+ellipse(161,52,47,23,'none',edge,2)
asset("keys-front",keys+ring)
lock = rect(239,81,46,65,copper,edge,6)+path('M263 96q-14 1-5 14l-3 18h16l-4-18q9-13-4-14Z','#2b2921',edge,2)
asset("keys-back",keys+ring+lock+mark(266,111))
asset("keys-open",keys+ring+lock+mark(99,127)+mark(198,141))
asset("keys-detail",keys+ring+lock+caption_card(209,151,'M219 175h14v-9h7v9h13v-13h7v13h11'))

# Suitcase, hidden compartment with matching accession slips
luggage = rect(44,57,233,109,wood,edge,14)+path('M128 57V43Q128 30 144 30h30q18 0 18 13v14',stroke=copper,w=10)
luggage += rect(66,66,26,91,red,edge,4)+rect(226,66,26,91,red,edge,4)
luggage += rect(68,94,21,25,copper,corner=3)+rect(229,94,21,25,copper,corner=3)
luggage += lines('M52 80h217','M56 143h206','M104 71h99','M106 157h90',stroke='#ce9267',w=1)
asset("suitcase-front",luggage+rect(151,99,21,18,copper,corner=4))
asset("suitcase-back",group(luggage,'rotate(-9 160 105)')+mark(154,137))
trunkOpen = path('M45 101L61 37L255 33L276 101Z',wood,edge,4)+path('M61 91L72 47l173-4 14 48Z',red,edge,2)+rect(42,98,236,87,wood,edge,10)+rect(53,105,216,66,green,edge,5)
trunkOpen += rect(92,111,133,51,wood,edge,4)+rect(143,128,32,11,copper,corner=3)+mark(159,134)
asset("suitcase-open",trunkOpen)
asset("suitcase-detail",trunkOpen+rect(94,113,129,47,'#25231a',edge,4)+caption_card(107,115,'M116 127h54m-54 8h43m-43 8h31')+
      group(caption_card(147,123,'M157 135h50m-49 8h39m-38 8h31'),'rotate(7 190 148)'))

# Portrait studies. All silhouettes share the same scale, with individual profiles and workwear.
cloth = ['#593530','#3e494d','#504939','#3c5260','#635442','#435146','#623a4a','#4a4236',
         '#715147','#4c495b','#324d50','#4f5340','#493e57','#685341','#552e35','#343e50',
         '#715842','#574536','#3d4656','#664c3d','#475348','#683f44','#4f4639','#3f4944']
skin = ['#c98d6b','#d2a37c','#a96f56','#d1a07a','#c88d60','#a76e53','#c89b79','#d1aa82']
hair = ['#2c2224','#3d3132','#584039','#72726a','#4b2824','#252a28']
case_ids = ['box','umbrella','thermos','punch','mittens','glasses','metronome','lantern','puppet','camera','keys','suitcase']
for index, name in enumerate(case_ids):
    for j in range(2):
        k = 2 * index + j
        skin_color = skin[k % len(skin)]
        hair_color = hair[(k * 5 + index) % len(hair)]
        coat = cloth[k]
        rim = '#ca9262'
        bust = path('M18 178Q20 149 42 136L67 126L74 113L98 107L111 129L138 142Q151 154 152 178Z',coat,rim,2)
        bust += path('M68 124L80 112l19 1 13 23-22 17Z',skin_color,outline,2)
        brow = 101 + k % 4 * 2
        chin = 102 + k % 3 * 4
        bust += path(f'M57 98Q49 78 56 55Q63 34 90 34Q111 37 115 56L{brow+11} 69L128 87L118 91L122 98L115 103Q119 118 {chin} 120L89 115Q80 109 75 103Z',skin_color,outline,2)
        if k % 4 == 0:
            bust += path('M52 104Q40 87 49 57Q59 30 86 32Q106 31 117 53L94 44Q86 49 82 72L73 99L81 128L55 125Z',hair_color,rim,1)
        elif k % 4 == 1:
            bust += path('M52 93Q41 80 49 56Q56 35 82 33Q101 31 113 45L118 58L99 54L87 58L73 79L67 103Z',hair_color,rim,1)
            bust += path('M84 30Q118 31 121 47L140 52Q149 57 140 59L47 58Q41 47 55 41L64 28Z',coat,rim,2)
        elif k % 4 == 2:
            bust += path('M49 78Q39 61 53 42Q64 25 87 31Q103 29 115 48L105 51L99 44Q81 62 75 84L73 106L54 110Z',hair_color,rim,1)
            bust += ellipse(52,95,13,13,hair_color,rim,1)
        else:
            bust += path('M49 91Q42 67 49 49Q62 35 89 35Q108 33 117 55L103 51L88 60L80 81L74 104Z',hair_color,rim,1)
            bust += lines('M113 93l7 5','M111 96l8 5',stroke=hair_color,w=2)
        bust += lines(f'M{brow} 72l12 -2','M116 99l6 1','M72 83q7-6 10 2q-1 6-5 8',stroke=outline,w=2)
        bust += ellipse(brow+8,76,2.3,1.6,outline,'none',0)
        bust += path('M66 124L88 148L46 144Z',coat,rim,2)+path('M110 126L90 149L123 155Z',coat,rim,2)
        bust += lines('M40 161l-2 18','M88 151v27',stroke=rim,w=1)
        bust += ellipse(97,166,2,2,copper,'none',0)
        if k == 0:
            bust += lines('M43 150l-4 8','M54 155l-4 8','M35 163l-4 7',stroke='#96a39b',w=1)
        if k == 1:
            bust += path('M104 178l7-30 35 4 7 26Z',paper,edge,1)+lines('M116 158l23 3','M115 163l27 4','M114 169l29 4',stroke='#704333',w=1)
        if j == 1:
            bust = group(bust,'translate(180 0) scale(-1 1)')
        asset(f'{name}-person-{j}',bust,"8 18 155 161")

rate = 24000
random.seed(411)
def wave_file(name,length,parts):
    data = []
    for i in range(round(length*rate)):
        t = i/rate
        value = 0.0
        for start, hz, amp, damp, span in parts:
            u = t - start
            if 0 <= u < span:
                envelope = min(1.0, u / .003, (span-u) / .015) * math.exp(-damp * u)
                signal = math.sin(2*math.pi*hz*u) if hz else random.uniform(-1,1)
                value += amp * envelope * signal
        data.append(struct.pack("<h", round(max(-1,min(1,value))*32767)))
    with wave.open(str(root/(name+".wav")), "wb") as audio:
        audio.setparams((1,2,rate,0,"NONE","not compressed"))
        audio.writeframes(b"".join(data))
wave_file('bell',.9,[(0,698,.5,5,.88),(0,1109,.23,8,.66),(.004,1781,.13,10,.45),(0,0,.09,90,.07)])
wave_file('click',.22,[(0,810,.23,46,.13),(0,0,.52,43,.15),(.052,495,.21,52,.12),(.053,0,.18,75,.09)])
wave_file('stamp',.47,[(0,72,.68,16,.35),(0,137,.33,22,.17),(0,0,.39,36,.13),(.126,87,.12,50,.17)])
wave_file('melody',2.3,[(t,h*f,amp,damp,.81) for t,f in [(0,783.99),(.34,987.77),(.68,1174.66),(1.25,987.77)]
                       for h,amp,damp in [(1,.45,6),(2,.12,7),(3.013,.05,12)]])
wave_file('ticks',2.34,[(t,f,a,60,.12) for t in [0,.45,.9,1.53,1.98] for f,a in [(0,.34),(765,.26),(244,.14)]])
