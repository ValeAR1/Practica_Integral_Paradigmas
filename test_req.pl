:- [server].

test :-
    Datos = _{
        temperatura: 18,
        lluvia: "no",
        ocasion: "casual",
        prendas: [
  {"id":"seed-0","name":"Blusa de seda blanca","category":"superior","color":"blanco","warmth":2,"style":"elegante","emoji":"👚"},
  {"id":"seed-1","name":"Camisa Oxford azul","category":"superior","color":"azul","warmth":2,"style":"formal","emoji":"👔"},
  {"id":"seed-2","name":"Top negro básico","category":"superior","color":"negro","warmth":1,"style":"casual","emoji":"👕"},
  {"id":"seed-3","name":"Suéter oversized beige","category":"superior","color":"beige","warmth":4,"style":"casual","emoji":"🧶"},
  {"id":"seed-4","name":"Cardigan gris","category":"superior","color":"gris","warmth":3,"style":"casual","emoji":"🧥"},
  {"id":"seed-5","name":"Hoodie rosa","category":"superior","color":"rosa","warmth":3,"style":"deportivo","emoji":"🧥"},
  {"id":"seed-6","name":"Jeans skinny azul","category":"inferior","color":"azul","warmth":2,"style":"casual","emoji":"👖"},
  {"id":"seed-7","name":"Jeans mom negros","category":"inferior","color":"negro","warmth":2,"style":"casual","emoji":"👖"},
  {"id":"seed-8","name":"Pantalón de vestir beige","category":"inferior","color":"beige","warmth":3,"style":"formal","emoji":"👖"},
  {"id":"seed-9","name":"Pantalón sastre negro","category":"inferior","color":"negro","warmth":3,"style":"formal","emoji":"👖"},
  {"id":"seed-10","name":"Falda midi plisada","category":"inferior","color":"verde","warmth":2,"style":"elegante","emoji":"👗"},
  {"id":"seed-11","name":"Vestido midi negro","category":"vestido","color":"negro","warmth":2,"style":"elegante","emoji":"👗"},
  {"id":"seed-12","name":"Vestido floral de verano","category":"vestido","color":"multicolor","warmth":1,"style":"casual","emoji":"👗"},
  {"id":"seed-13","name":"Vestido cóctel rojo","category":"vestido","color":"rojo","warmth":3,"style":"elegante","emoji":"👗"},
  {"id":"seed-14","name":"Tenis blancos","category":"calzado","color":"blanco","warmth":1,"style":"casual","emoji":"👟"},
  {"id":"seed-15","name":"Tenis deportivos","category":"calzado","color":"negro","warmth":2,"style":"deportivo","emoji":"👟"},
  {"id":"seed-16","name":"Zapatos de tacón negros","category":"calzado","color":"negro","warmth":2,"style":"elegante","emoji":"👠"},
  {"id":"seed-17","name":"Mocasines beige","category":"calzado","color":"beige","warmth":2,"style":"formal","emoji":"👞"},
  {"id":"seed-18","name":"Botas de lluvia amarillas","category":"calzado","color":"amarillo","warmth":3,"style":"casual","emoji":"🥾"},
  {"id":"seed-19","name":"Botas de lluvia negras","category":"calzado","color":"negro","warmth":3,"style":"casual","emoji":"🥾"},
  {"id":"seed-20","name":"Gabardina beige","category":"abrigo","color":"beige","warmth":4,"style":"formal","emoji":"🧥"},
  {"id":"seed-21","name":"Chamarra de piel negra","category":"abrigo","color":"negro","warmth":3,"style":"casual","emoji":"🧥"},
  {"id":"seed-22","name":"Abrigo de lana gris","category":"abrigo","color":"gris","warmth":5,"style":"elegante","emoji":"🧥"},
  {"id":"seed-23","name":"Impermeable transparente","category":"abrigo","color":"transparente","warmth":3,"style":"casual","emoji":"🌂"},
  {"id":"seed-24","name":"Chamarra impermeable azul","category":"abrigo","color":"azul","warmth":4,"style":"casual","emoji":"🧥"},
  {"id":"seed-25","name":"Bolso de mano negro","category":"accesorio","color":"negro","warmth":1,"style":"elegante","emoji":"👜"},
  {"id":"seed-26","name":"Mochila casual","category":"accesorio","color":"gris","warmth":1,"style":"casual","emoji":"🎒"},
  {"id":"seed-27","name":"Bufanda de lana roja","category":"accesorio","color":"rojo","warmth":4,"style":"casual","emoji":"🧣"},
  {"id":"seed-28","name":"Collar dorado elegante","category":"accesorio","color":"dorado","warmth":1,"style":"elegante","emoji":"📿"},
  {"id":"seed-29","name":"Paraguas negro","category":"accesorio","color":"negro","warmth":1,"style":"casual","emoji":"☂️"},
  {"id":"seed-30","name":"Paraguas transparente","category":"accesorio","color":"transparente","warmth":1,"style":"elegante","emoji":"☂️"}
]
    },
    procesar_recomendacion(Datos).
