require! {
  fs
  request
  async
  zlib
}
obce =
  * id: 552666, nazev: "Malšice"
  * id: 574716, nazev: "Pardubice I"
  * id: 555762, nazev: "Žlutice"
  * id: 565717, nazev: "Terezín"
  * id: 549240, nazev: "Písek"
  * id: 554642, nazev: "Mariánské Lázně"
  * id: 568414, nazev: "Havlíčkův Brod"
  * id: 523704, nazev: "Šumperk"
  * id: 537454, nazev: "Lysá nad Labem"
  * id: 545970, nazev: "Plzeň I"
# obce.length = 1
mergeObvody = (data, parent) ->
  data.zastupitele = []
  for obvod in data.obvody
    obvod.hlasu = 0
    for strana in obvod.strany => obvod.hlasu += strana.hlasu
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

(err, data) <~ async.map obce, (obec, cb) ->
  (err, response, body) <~ request.get do
    url: "http://smzkomunalky.blob.core.windows.net/vysledky/#{obec.id}.json"
    encoding: null
    gzip: true
  (err, data) <~ zlib.gunzip body
  data = JSON.parse data
  zastupitelstvo = mergeObvody data.obec
  nazev = obec.nazev
  cb null, {nazev, zastupitelstvo}
fs.writeFile "#__dirname/../data/obce.json", JSON.stringify data
