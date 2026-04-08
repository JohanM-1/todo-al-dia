export const defaultLocale = 'en' as const;

export const locales = ['en', 'es'] as const;

export type Locale = (typeof locales)[number];

type LandingContent = {
  htmlLang: string;
  a11y: {
    skipToContent: string;
    brandHome: string;
    mainNav: string;
    localeSwitcher: string;
    heroPreviewAlt: string;
    heroActions: string;
    checkpoints: string;
    pills: string;
  };
  seo: {
    title: string;
    description: string;
  };
  nav: {
    howItWorks: string;
    faq: string;
  };
  ctas: {
    app: string;
    appShort: string;
    seeHow: string;
    backToTop: string;
  };
  hero: {
    eyebrow: string;
    title: string;
    lead: string;
    microcopy: string;
  };
  sideCard: {
    badge: string;
    title: string;
    body: string;
    checkpoints: Array<{ label: string; text: string }>;
    pills: string[];
  };
  benefits: {
    eyebrow: string;
    title: string;
    intro: string;
    items: Array<{ title: string; description: string }>;
  };
  features: {
    eyebrow: string;
    title: string;
    intro: string;
    points: string[];
  };
  steps: {
    eyebrow: string;
    title: string;
    intro: string;
    items: Array<{ title: string; description: string }>;
    panel: {
      title: string;
      body: string;
      points: string[];
    };
  };
  faq: {
    eyebrow: string;
    title: string;
    items: Array<{ question: string; answer: string }>;
  };
  closing: {
    eyebrow: string;
    title: string;
    body: string;
  };
  footer: {
    tagline: string;
  };
  analytics: {
    destinationLabel: string;
  };
  structuredData: {
    featureList: string[];
  };
};

export const landingContent: Record<Locale, LandingContent> = {
  en: {
    htmlLang: 'en',
    a11y: {
      skipToContent: 'Skip to main content',
      brandHome: 'Go to TodoAlDia homepage',
      mainNav: 'Main navigation',
      localeSwitcher: 'Language switcher',
      heroPreviewAlt: 'Preview of TodoAlDia with balance, movements, and goals',
      heroActions: 'Primary actions',
      checkpoints: 'Key benefits',
      pills: 'Product pillars',
    },
    seo: {
      title: 'TodoAlDia | Track expenses in seconds and understand your money',
      description:
        'Track expenses and income with voice or text, understand where your money goes, and start organizing your finances without endless spreadsheets.',
    },
    nav: {
      howItWorks: 'How it works',
      faq: 'FAQ',
    },
    ctas: {
      app: 'Open the app',
      appShort: 'Open app',
      seeHow: 'See how it works',
      backToTop: 'Back to top',
    },
    hero: {
      eyebrow: 'Personal finances without friction',
      title: 'Track your expenses in seconds and understand where your money goes.',
      lead:
        'Forget endless spreadsheets. With TodoAlDia, you can log what you spent with a voice note or text and get financial clarity right away.',
      microcopy: 'No credit card required. Start getting organized today.',
    },
    sideCard: {
      badge: 'Take control today',
      title: 'Less mental effort to log, more clarity to decide.',
      body:
        'Log quickly, understand what is happening with your money, and make better decisions from your phone or the web.',
      checkpoints: [
        {
          label: 'Result',
          text: 'You know exactly where you stand.',
        },
        {
          label: 'No mistakes',
          text: 'If something is missing, the app helps you right away.',
        },
        {
          label: 'Action',
          text: 'Ready to use from your phone or the web.',
        },
      ],
      pills: ['Fast', 'Clear', 'No friction'],
    },
    benefits: {
      eyebrow: 'What changes for you',
      title: 'Stop guessing where your money went. Start deciding.',
      intro:
        'An app that fits your pace, designed so keeping the habit of taking care of your money feels easy.',
      items: [
        {
          title: 'You log it before you forget',
          description:
            'Record an expense or income the moment it happens. Avoid the classic "I will add it later" that never happens and breaks your budget.',
        },
        {
          title: 'You see what is happening today',
          description:
            'Check your balance, categories, and monthly summary in one screen. Spot leaks fast and understand what needs attention.',
        },
        {
          title: 'You adjust without losing momentum',
          description:
            'Set goals and budgets you can actually follow, without cluttered screens or unnecessary complexity.',
        },
      ],
    },
    features: {
      eyebrow: 'Simple and powerful',
      title: 'Everything you need to stay on top of your money',
      intro:
        'The essentials to log faster, understand more clearly, and spend less time fighting with tools.',
      points: [
        'Smart expense logging by voice or text.',
        'Monthly summaries and current balance without visual noise.',
        'Clear budgets and goals to make better decisions.',
        'Always available wherever you are.',
      ],
    },
    steps: {
      eyebrow: 'Step by step',
      title: 'As easy as sending a message',
      intro:
        'The promise of speed is backed by a short, clear flow designed to keep you moving.',
      items: [
        {
          title: '1. Add the movement',
          description: 'Say or type what happened. The app does the heavy lifting for you.',
        },
        {
          title: '2. Confirm it instantly',
          description:
            'You get immediate feedback on what was understood and fix anything on the spot without starting over.',
        },
        {
          title: '3. Act with clarity',
          description:
            'Review what you have, what is draining your budget, and how you are doing against your monthly goals.',
        },
      ],
      panel: {
        title: 'No stress, no confusion',
        body:
          'If you forget an amount or a category is unclear, the app asks in a simple way so you can keep going without losing context.',
        points: [
          'Clear messages near the problem with no ambiguity.',
          'Quick corrections without restarting the whole flow.',
          'Empty states that invite you to add your first movement.',
        ],
      },
    },
    faq: {
      eyebrow: 'Quick answers',
      title: 'Just enough to remove doubt before you start',
      items: [
        {
          question: 'How do I start using TodoAlDia?',
          answer:
            'Tap "Open the app", create your account in seconds, and log your first expense of the day. That is it.',
        },
        {
          question: 'Why is it different from other apps?',
          answer:
            'Because it removes friction. Most apps make you fill out long forms; this one lets you log an expense with text or voice in less time than it takes to open your wallet.',
        },
        {
          question: 'Is my data safe?',
          answer:
            'Yes. Your information is private, and only you can access your balances and movements.',
        },
      ],
    },
    closing: {
      eyebrow: 'Your next step',
      title: 'If you want financial peace of mind, the next move is not more reading. It is trying the app.',
      body:
        'Start logging faster, understanding more clearly, and taking control of your money today.',
    },
    footer: {
      tagline: 'Personal finance without friction so organizing your money takes less effort.',
    },
    analytics: {
      destinationLabel: 'Flutter app',
    },
    structuredData: {
      featureList: ['Fast logging', 'Clear monthly summary', 'Goal tracking'],
    },
  },
  es: {
    htmlLang: 'es-AR',
    a11y: {
      skipToContent: 'Saltar al contenido principal',
      brandHome: 'Ir al inicio de TodoAlDia',
      mainNav: 'Navegacion principal',
      localeSwitcher: 'Selector de idioma',
      heroPreviewAlt: 'Vista previa de TodoAlDia con balance, movimientos y metas',
      heroActions: 'Acciones principales',
      checkpoints: 'Beneficios principales',
      pills: 'Pilares del producto',
    },
    seo: {
      title: 'TodoAlDia | Registra tus gastos en segundos y entiende tu plata',
      description:
        'Registra gastos e ingresos con voz o texto, entiende a donde va tu plata y empieza a ordenar tus finanzas sin planillas eternas.',
    },
    nav: {
      howItWorks: 'Como funciona',
      faq: 'Preguntas',
    },
    ctas: {
      app: 'Abrir la app',
      appShort: 'Ir a la app',
      seeHow: 'Ver como funciona',
      backToTop: 'Volver arriba',
    },
    hero: {
      eyebrow: 'Finanzas personales sin friccion',
      title: 'Registra tus gastos en segundos y entiende a donde va tu plata.',
      lead:
        'Olvidate de las planillas eternas. Con TodoAlDia, anotas lo que gastaste con un mensaje de voz o texto y obtienes claridad financiera al instante.',
      microcopy: 'Sin tarjeta de credito. Empieza a ordenarte hoy.',
    },
    sideCard: {
      badge: 'Toma el control hoy mismo',
      title: 'Menos carga mental para registrar, mas claridad para decidir.',
      body:
        'Anota rapido, entiende que esta pasando con tu plata y toma decisiones con contexto desde el celular o la web.',
      checkpoints: [
        {
          label: 'Resultado',
          text: 'Sabes exactamente donde estas parado.',
        },
        {
          label: 'Sin errores',
          text: 'Si falta un dato, la app te ayuda al instante.',
        },
        {
          label: 'Accion',
          text: 'Todo listo para usar desde tu celular o web.',
        },
      ],
      pills: ['Rapido', 'Claro', 'Sin vueltas'],
    },
    benefits: {
      eyebrow: 'Lo que cambia para vos',
      title: 'Deja de adivinar en que gastaste. Empieza a decidir.',
      intro:
        'Una app que se adapta a tu ritmo, pensada para que no te cueste mantener el habito de cuidar tu plata.',
      items: [
        {
          title: 'Registras antes de olvidarte',
          description:
            'Anota un gasto o ingreso en el momento. Evita el clasico "despues lo cargo" que nunca pasa y arruina tu presupuesto.',
        },
        {
          title: 'Ves que esta pasando hoy',
          description:
            'Mira tu balance, categorias y resumen mensual en una sola pantalla. Detecta rapido por donde se fuga la plata.',
        },
        {
          title: 'Ajustas sin perder el ritmo',
          description:
            'Configura metas y presupuestos que de verdad puedas seguir, sin complicaciones ni pantallas sobrecargadas.',
        },
      ],
    },
    features: {
      eyebrow: 'Simple y potente',
      title: 'Todo lo que necesitas para estar al dia',
      intro:
        'Lo esencial para registrar rapido, entender mejor y no perder tiempo en herramientas complicadas.',
      points: [
        'Registro inteligente por voz o texto.',
        'Resumen del mes y balance actual sin ruido visual.',
        'Presupuestos y metas claras para decidir mejor.',
        'Disponible siempre, vayas donde vayas.',
      ],
    },
    steps: {
      eyebrow: 'Paso a paso',
      title: 'Tan facil como mandar un mensaje',
      intro:
        'La promesa de rapidez se sostiene en un flujo corto, claro y pensado para que no pierdas el hilo.',
      items: [
        {
          title: '1. Cargas el movimiento',
          description: 'Dices o escribes que paso. La app hace el trabajo pesado por vos.',
        },
        {
          title: '2. Confirmas al toque',
          description:
            'Recibes feedback inmediato de lo que cargaste. Corriges en el acto sin volver a empezar.',
        },
        {
          title: '3. Actuas con claridad',
          description:
            'Revisas cuanto tienes, que te esta drenando el bolsillo y como vienes con tus objetivos del mes.',
        },
      ],
      panel: {
        title: 'Sin estres ni errores',
        body:
          'Si te olvidas de poner un monto o la categoria no queda clara, la app te lo pregunta de forma simple para que sigas sin perder el hilo.',
        points: [
          'Mensajes concretos cerca del problema y sin ambiguedad.',
          'Correcciones inmediatas sin volver a arrancar el registro.',
          'Estados vacios que te invitan a cargar tu primer movimiento.',
        ],
      },
    },
    faq: {
      eyebrow: 'Dudas rapidas',
      title: 'Lo justo para despejar dudas antes de empezar',
      items: [
        {
          question: 'Como empiezo a usar TodoAlDia?',
          answer:
            'Tocas "Abrir la app", creas tu cuenta en segundos y registras tu primer gasto del dia. Asi de directo.',
        },
        {
          question: 'Por que es diferente a otras apps?',
          answer:
            'Porque elimina la friccion. En vez de llenarte de formularios largos, te deja registrar un gasto con texto o voz en menos de lo que tardas en abrir la billetera.',
        },
        {
          question: 'Mis datos estan seguros?',
          answer:
            'Si. Tu informacion es privada y solo vos tienes acceso a tus balances y movimientos.',
        },
      ],
    },
    closing: {
      eyebrow: 'Tu proximo paso',
      title: 'Si quieres tranquilidad financiera, la solucion no es seguir leyendo: es probar la app.',
      body:
        'Empieza a registrar rapido, a entender mejor y a tomar el control de tu plata hoy mismo.',
    },
    footer: {
      tagline: 'Finanzas personales sin friccion para ordenar tu plata con menos esfuerzo.',
    },
    analytics: {
      destinationLabel: 'Aplicacion Flutter',
    },
    structuredData: {
      featureList: ['Registro rapido', 'Resumen claro', 'Seguimiento de objetivos'],
    },
  },
};

export function resolveLocale(value?: string | null): Locale {
  const normalized = value?.trim().toLowerCase();

  if (!normalized) {
    return defaultLocale;
  }

  if (normalized === 'es' || normalized.startsWith('es-')) {
    return 'es';
  }

  return 'en';
}
