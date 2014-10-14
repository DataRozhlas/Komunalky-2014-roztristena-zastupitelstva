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
(err, data) <~ async.map obce, (obec, cb) ->
  (err, response, body) <~ request.get do
    url: "http://smzkomunalky.blob.core.windows.net/vysledky/#{obec.id}.json"
    encoding: null
    gzip: true
  (err, data) <~ zlib.gunzip body
  data = JSON.parse data
  zastupitelstvo = data.obec
  nazev = obec.nazev
  cb null, {nazev, zastupitelstvo}
fs.writeFile "#__dirname/../data/obce.json", JSON.stringify data
