mergeObvody = (data, parent) ->
  data.zastupitele = []
  for obvod in data.obvody
    obvod.hlasu = 0
    for strana in obvod.strany => obvod.hlasu += strana.hlasu
    obvod.strany.sort (a, b) ->
      | b.hlasu - a.hlasu => that
      | otherwise => b.id - a.id

    for strana in obvod.strany
      stranaData =
        id: strana.id
        nazev: strana.nazev
        hlasu: strana.hlasu
        procent: strana.hlasu / obvod.hlasu
        zastupitelu: strana.zastupitelu
      if strana.zastupitele
        for zastupitel, zastupitelIndex in strana.zastupitele
          data.zastupitele.push do
            jmeno: zastupitel.jmeno
            prijmeni: zastupitel.prijmeni
            strana: stranaData
            poradi: zastupitelIndex + 1
            hlasu: zastupitel.hlasu
            parent: parent
      else if strana.zastupitelu
        for zastupitelIndex in [0 til strana.zastupitelu]
          data.zastupitele.push do
            strana: stranaData
            poradi: zastupitelIndex + 1
            parent: parent
  data

knownStrany =
  "1"   : \#FEE300
  "5"   : \#0FB103
  "7"   : \#FEA201
  "47"  : \#F40000
  "53"  : \#1C76F0
  "144" : \#66E2D8
  "156" : \#B55E01
  "192" : \#66E2D8
  "720" : \#504E4F
  "721" : \#B560F3
  "764" : \#990422
  "768" : \#5434A3
  "792" : \#B3C382

init = ->
  new Tooltip!watchElements!
  utils = window.ig.utils
  kosti = window.ig.data.obce
  kostiCont = d3.select '.ig.ig-kosti'
  width = kostiCont.0.0.offsetWidth
  kostSide = 28
  kostiX = Math.floor width / kostSide
  kostiAssoc = {}
  for datum in kosti
    mergeObvody datum.zastupitelstvo, datum
    datum.rows = Math.ceil datum.zastupitelstvo.zastupitele.length / kostiX
    for zastupitel, index in datum.zastupitelstvo.zastupitele
      zastupitel.index = index
    kostiAssoc[datum.nazev] = datum
  typy = d3.selectAll \.ig.ig-kosti
    ..datum (d, i) ->
      id = @getAttribute 'data-ig'
      kostiAssoc[id]
    ..attr \class "ig typ active"
    ..append \h3
      ..html (.nazev)
    ..append \div
      ..attr \class \kosti
      ..style \height -> "#{it.rows * kostSide}px"

  currentKosti = typy.select \.kosti
    ..selectAll \.kost.active .data (.zastupitelstvo.zastupitele)
      ..enter!append \div
        ..attr \class "kost active activating"
  color = d3.scale.category20!
  currentKost = currentKosti.selectAll \.kost.active
    ..style \background-color ->
      | knownStrany[it.strana.id] => that
      | otherwise => color "#{it.strana.id}#{it.strana.nazev}"
    ..style "top" (d) ~>
        "#{(d.index % d.parent.rows) * kostSide}px"
    ..style "left" (d) ~>
        "#{(Math.floor d.index / d.parent.rows) * kostSide}px"
    ..attr \data-tooltip ~>
      out = if it.jmeno
        "<b>#{it.jmeno} #{it.prijmeni}</b><br>
        Získal #{it.hlasu} hlasů<br />"
      else
        "<b>Zastupitel za #{it.strana.nazev}</b><br>"
      zastupiteluString =
        | 0 < it.strana.zastupitelu < 5 => 'zastupitele'
        | otherwise => 'zastupitelů'
      out += "#{it.strana.nazev} získala #{utils.percentage it.strana.procent} % hlasů, #{it.strana.zastupitelu} #zastupiteluString<br>"
      out
if d3?
  init!
else
  $ window .bind \load ->
    if d3?
      init!
