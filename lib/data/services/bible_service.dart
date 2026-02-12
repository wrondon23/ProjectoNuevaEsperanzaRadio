import 'dart:math';

class VerseModel {
  final String text;
  final String reference;
  final String version;

  const VerseModel({
    required this.text,
    required this.reference,
    this.version = 'RVR1960',
  });
}

class BibleService {
  // Singleton pattern
  static final BibleService _instance = BibleService._internal();
  factory BibleService() => _instance;
  BibleService._internal();

  VerseModel getDailyVerse() {
    final now = DateTime.now();
    // Use the day of the year to pick a verse, ensuring it changes daily but stays same for everyone
    final dayOfYear = int.parse(
        "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}");

    // Seed random with the date so it's deterministic for the day
    final random = Random(dayOfYear);
    final index = random.nextInt(_verses.length);

    return _verses[index];
  }

  static const List<VerseModel> _verses = [
    VerseModel(
        text:
            "Porque de tal manera amó Dios al mundo, que ha dado a su Hijo unigénito, para que todo aquel que en él cree, no se pierda, mas tenga vida eterna.",
        reference: "Juan 3:16"),
    VerseModel(
        text: "Jehová es mi pastor; nada me faltará.",
        reference: "Salmos 23:1"),
    VerseModel(
        text: "Todo lo puedo en Cristo que me fortalece.",
        reference: "Filipenses 4:13"),
    VerseModel(
        text:
            "Mas buscad primeramente el reino de Dios y su justicia, y todas estas cosas os serán añadidas.",
        reference: "Mateo 6:33"),
    VerseModel(
        text:
            "Fíate de Jehová de todo tu corazón, Y no te apoyes en tu propia prudencia.",
        reference: "Proverbios 3:5"),
    VerseModel(
        text:
            "Mira que te mando que te esfuerces y seas valiente; no temas ni desmayes, porque Jehová tu Dios estará contigo en dondequiera que vayas.",
        reference: "Josué 1:9"),
    VerseModel(
        text:
            "Y sabemos que a los que aman a Dios, todas las cosas les ayudan a bien, esto es, a los que conforme a su propósito son llamados.",
        reference: "Romanos 8:28"),
    VerseModel(
        text:
            "Clama a mí, y yo te responderé, y te enseñaré cosas grandes y ocultas que tú no conoces.",
        reference: "Jeremías 33:3"),
    VerseModel(
        text:
            "Porque yo sé los pensamientos que tengo acerca de vosotros, dice Jehová, pensamientos de paz, y no de mal, para daros el fin que esperáis.",
        reference: "Jeremías 29:11"),
    VerseModel(
        text: "Lámpara es a mis pies tu palabra, Y lumbrera a mi camino.",
        reference: "Salmos 119:105"),
    VerseModel(
        text:
            "Venid a mí todos los que estáis trabajados y cargados, y yo os haré descansar.",
        reference: "Mateo 11:28"),
    VerseModel(
        text:
            "Pero los que esperan a Jehová tendrán nuevas fuerzas; levantarán alas como las águilas; correrán, y no se cansarán; caminarán, y no se fatigarán.",
        reference: "Isaías 40:31"),
    VerseModel(
        text:
            "No se inquieten por nada; más bien, en toda ocasión, con oración y ruego, presenten sus peticiones a Dios y denle gracias.",
        reference: "Filipenses 4:6"),
    VerseModel(
        text:
            "El Señor es mi luz y mi salvación; ¿a quién temeré? El Señor es el baluarte de mi vida; ¿quién podrá amedrentarme?",
        reference: "Salmos 27:1"),
    VerseModel(
        text: "Encomienda a Jehová tu camino, Y confía en él; y él hará.",
        reference: "Salmos 37:5"),
    VerseModel(
        text:
            "He peleado la buena batalla, he acabado la carrera, he guardado la fe.",
        reference: "2 Timoteo 4:7"),
    VerseModel(
        text:
            "Porque por gracia sois salvos por medio de la fe; y esto no de vosotros, pues es don de Dios.",
        reference: "Efesios 2:8"),
    VerseModel(
        text:
            "Si confesamos nuestros pecados, él es fiel y justo para perdonar nuestros pecados, y limpiarnos de toda maldad.",
        reference: "1 Juan 1:9"),
    VerseModel(
        text:
            "Y la paz de Dios, que sobrepasa todo entendimiento, guardará vuestros corazones y vuestros pensamientos en Cristo Jesús.",
        reference: "Filipenses 4:7"),
    VerseModel(
        text:
            "Cercano está Jehová a los quebrantados de corazón; Y salva a los contritos de espíritu.",
        reference: "Salmos 34:18"),
    // Nuevos versículos agregados para variedad diaria
    VerseModel(
        text:
            "El amor es sufrido, es benigno; el amor no tiene envidia, el amor no es jactancioso, no se envanece.",
        reference: "1 Corintios 13:4"),
    VerseModel(
        text:
            "Mas el fruto del Espíritu es amor, gozo, paz, paciencia, benignidad, bondad, fe, mansedumbre, templanza.",
        reference: "Gálatas 5:22-23"),
    VerseModel(
        text:
            "Por nada estéis afanosos, sino sean conocidas vuestras peticiones delante de Dios en toda oración y ruego, con acción de gracias.",
        reference: "Filipenses 4:6"),
    VerseModel(
        text:
            "Y la paz de Dios, que sobrepasa todo entendimiento, guardará vuestros corazones y vuestros pensamientos en Cristo Jesús.",
        reference: "Filipenses 4:7"),
    VerseModel(
        text:
            "Todo tiene su tiempo, y todo lo que se quiere debajo del cielo tiene su hora.",
        reference: "Eclesiastés 3:1"),
    VerseModel(
        text:
            "El que habita al abrigo del Altísimo morará bajo la sombra del Omnipotente.",
        reference: "Salmos 91:1"),
    VerseModel(
        text:
            "Diré yo a Jehová: Esperanza mía, y castillo mío; Mi Dios, en quien confiaré.",
        reference: "Salmos 91:2"),
    VerseModel(
        text:
            "Porque él te librará del lazo del cazador, de la peste destructora.",
        reference: "Salmos 91:3"),
    VerseModel(
        text:
            "Con sus plumas te cubrirá, y debajo de sus alas estarás seguro; escudo y adarga es su verdad.",
        reference: "Salmos 91:4"),
    VerseModel(
        text:
            "No temas, porque yo estoy contigo; no desmayes, porque yo soy tu Dios que te esfuerzo; siempre te ayudaré, siempre te sustentaré con la diestra de mi justicia.",
        reference: "Isaías 41:10"),
    VerseModel(
        text:
            "Jehová es mi luz y mi salvación; ¿de quién temeré? Jehová es la fortaleza de mi vida; ¿de quién he de atemorizarme?",
        reference: "Salmos 27:1"),
    VerseModel(
        text:
            "Instruye al niño en su camino, y aun cuando fuere viejo no se apartará de él.",
        reference: "Proverbios 22:6"),
    VerseModel(
        text:
            "El principio de la sabiduría es el temor de Jehová; los insensatos desprecian la sabiduría y la enseñanza.",
        reference: "Proverbios 1:7"),
    VerseModel(
        text:
            "Hijo mío, no te olvides de mi ley, y tu corazón guarde mis mandamientos.",
        reference: "Proverbios 3:1"),
    VerseModel(
        text: "Porque largura de días y años de vida y paz te aumentarán.",
        reference: "Proverbios 3:2"),
    VerseModel(
        text:
            "Nunca se aparten de ti la misericordia y la verdad; átalas a tu cuello, escríbelas en la tabla de tu corazón.",
        reference: "Proverbios 3:3"),
    VerseModel(
        text:
            "Y hallarás gracia y buena opinión ante los ojos de Dios y de los hombres.",
        reference: "Proverbios 3:4"),
    VerseModel(
        text: "Reconócelo en todos tus caminos, y él enderezará tus veredas.",
        reference: "Proverbios 3:6"),
    VerseModel(
        text:
            "No seas sabio en tu propia opinión; teme a Jehová, y apártate del mal.",
        reference: "Proverbios 3:7"),
    VerseModel(
        text: "Porque será medicina a tu cuerpo, y refrigerio para tus huesos.",
        reference: "Proverbios 3:8"),
    VerseModel(
        text:
            "Honra a Jehová con tus bienes, y con las primicias de todos tus frutos.",
        reference: "Proverbios 3:9"),
    VerseModel(
        text:
            "Y serán llenos tus graneros con abundancia, y tus lagares rebosarán de mosto.",
        reference: "Proverbios 3:10"),
    VerseModel(
        text:
            "No menosprecies, hijo mío, el castigo de Jehová, ni te fatigues de su corrección.",
        reference: "Proverbios 3:11"),
    VerseModel(
        text:
            "Porque Jehová al que ama castiga, como el padre al hijo a quien quiere.",
        reference: "Proverbios 3:12"),
    VerseModel(
        text:
            "Bienaventurado el hombre que halla la sabiduría, y que obtiene la inteligencia.",
        reference: "Proverbios 3:13"),
    VerseModel(
        text:
            "Porque su ganancia es mejor que la ganancia de la plata, y sus frutos más que el oro fino.",
        reference: "Proverbios 3:14"),
    VerseModel(
        text:
            "Más preciosa es que las piedras preciosas; y todo lo que puedes desear, no se puede comparar a ella.",
        reference: "Proverbios 3:15"),
    VerseModel(
        text:
            "Largura de días está en su mano derecha; en su izquierda, riquezas y honra.",
        reference: "Proverbios 3:16"),
    VerseModel(
        text: "Sus caminos son caminos deleitosos, y todas sus veredas paz.",
        reference: "Proverbios 3:17"),
    VerseModel(
        text:
            "Ella es árbol de vida a los que de ella echan mano, y bienaventurados son los que la retienen.",
        reference: "Proverbios 3:18"),
    VerseModel(
        text:
            "Jehová con sabiduría fundó la tierra; afirmó los cielos con inteligencia.",
        reference: "Proverbios 3:19"),
    VerseModel(
        text:
            "Con su ciencia los abismos fueron divididos, y destilan rocío los cielos.",
        reference: "Proverbios 3:20"),
    VerseModel(
        text:
            "Hijo mío, no se aparten estas cosas de tus ojos; guarda la ley y el consejo.",
        reference: "Proverbios 3:21"),
    VerseModel(
        text: "Y serán vida a tu alma, y gracia a tu cuello.",
        reference: "Proverbios 3:22"),
    VerseModel(
        text:
            "Entonces andarás por tu camino confiadamente, y tu pie no tropezará.",
        reference: "Proverbios 3:23"),
    VerseModel(
        text:
            "Cuando te acuestes, no tendrás temor, sino que te acostarás, y tu sueño será grato.",
        reference: "Proverbios 3:24"),
    VerseModel(
        text:
            "No tendrás temor de pavor repentino, ni de la ruina de los impíos cuando viniere.",
        reference: "Proverbios 3:25"),
    VerseModel(
        text:
            "Porque Jehová será tu confianza, y él preservará tu pie de quedar preso.",
        reference: "Proverbios 3:26"),
    VerseModel(
        text:
            "No te niegues a hacer el bien a quien es debido, cuando tuvieres poder para hacerlo.",
        reference: "Proverbios 3:27"),
    VerseModel(
        text:
            "No digas a tu prójimo: Anda, y vuelve, y mañana te daré, cuando tienes contigo qué darle.",
        reference: "Proverbios 3:28"),
    VerseModel(
        text:
            "No intentes mal contra tu prójimo que habita confiado junto a ti.",
        reference: "Proverbios 3:29"),
    VerseModel(
        text:
            "No tengas pleito con nadie sin razón, si no te han hecho agravio.",
        reference: "Proverbios 3:30"),
    VerseModel(
        text:
            "No envidies al hombre injusto, ni escojas ninguno de sus caminos.",
        reference: "Proverbios 3:31"),
    VerseModel(
        text:
            "Porque Jehová abomina al perverso; mas su comunión íntima es con los justos.",
        reference: "Proverbios 3:32"),
    VerseModel(
        text:
            "La maldición de Jehová está en la casa del impío, pero bendecirá la morada de los justos.",
        reference: "Proverbios 3:33"),
    VerseModel(
        text:
            "Ciertamente él escarnecerá a los escarnecedores, y a los humildes dará gracia.",
        reference: "Proverbios 3:34"),
    VerseModel(
        text: "Los sabios heredarán honra, mas los necios llevarán ignominia.",
        reference: "Proverbios 3:35"),
    VerseModel(
        text:
            "Justificados, pues, por la fe, tenemos paz para con Dios por medio de nuestro Señor Jesucristo.",
        reference: "Romanos 5:1"),
    VerseModel(
        text:
            "Mas Dios muestra su amor para con nosotros, en que siendo aún pecadores, Cristo murió por nosotros.",
        reference: "Romanos 5:8"),
    VerseModel(
        text:
            "Asi que, hermanos, os ruego por las misericordias de Dios, que presentéis vuestros cuerpos en sacrificio vivo, santo, agradable a Dios.",
        reference: "Romanos 12:1"),
    VerseModel(
        text:
            "No os conforméis a este siglo, sino transformaos por medio de la renovación de vuestro entendimiento.",
        reference: "Romanos 12:2"),
    VerseModel(
        text:
            "Gozaos en la esperanza; sufridos en la tribulación; constantes en la oración.",
        reference: "Romanos 12:12"),
    VerseModel(
        text: "No seas vencido de lo malo, sino vence con el bien el mal.",
        reference: "Romanos 12:21"),
    VerseModel(
        text:
            "Porque ninguno de nosotros vive para sí, y ninguno muere para sí.",
        reference: "Romanos 14:7"),
    VerseModel(
        text:
            "Así que, si vivimos, para el Señor vivimos; y si morimos, para el Señor morimos.",
        reference: "Romanos 14:8"),
    VerseModel(
        text:
            "Mas el Dios de esperanza os llene de todo gozo y paz en el creer.",
        reference: "Romanos 15:13"),
    VerseModel(
        text:
            "¿O ignoráis que vuestro cuerpo es templo del Espíritu Santo, el cual está en vosotros, el cual tenéis de Dios, y que no sois vuestros?",
        reference: "1 Corintios 6:19"),
    VerseModel(
        text:
            "Porque comprados sois por precio; glorificad, pues, a Dios en vuestro cuerpo y en vuestro espíritu, los cuales son de Dios.",
        reference: "1 Corintios 6:20"),
    VerseModel(
        text:
            "Velad, estad firmes en la fe; portaos varonilmente, y esforzaos.",
        reference: "1 Corintios 16:13"),
    VerseModel(
        text: "Todas vuestras cosas sean hechas con amor.",
        reference: "1 Corintios 16:14"),
    VerseModel(
        text: "Porque por fe andamos, no por vista.",
        reference: "2 Corintios 5:7"),
    VerseModel(
        text:
            "De modo que si alguno está en Cristo, nueva criatura es; las cosas viejas pasaron; he aquí todas son hechas nuevas.",
        reference: "2 Corintios 5:17"),
  ];
}
