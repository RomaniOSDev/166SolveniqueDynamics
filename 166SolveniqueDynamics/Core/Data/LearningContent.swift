import Foundation

enum LearningContent {
    // MARK: - Plain English

    static func plainEnglish(for term: LegalTerm) -> String {
        plainEnglishByName[term.name] ?? fallbackPlainEnglish(term)
    }

    private static func fallbackPlainEnglish(_ term: LegalTerm) -> String {
        "In everyday terms: \(term.briefDefinition)"
    }

    static let plainEnglishByName: [String: String] = [
        "Affidavit": "A sworn written statement — like signing a promise on paper that everything you wrote is true.",
        "Deposition": "Recorded Q&A outside court — lawyers ask questions and you answer under oath before trial.",
        "Subpoena": "An official order to show up or hand over documents — ignoring it can get you in trouble.",
        "Felony": "A serious crime that usually means prison time, not just a fine.",
        "Misdemeanor": "A smaller crime — still on your record, but lighter punishment than a felony.",
        "Habeas Corpus": "A way to challenge illegal jail time — the court checks if holding someone is lawful.",
        "Writ": "A formal court order telling someone to do something specific.",
        "Negligence": "Carelessness that hurts someone — you failed to be careful enough.",
        "Plaintiff": "The person who sues or starts the civil case.",
        "Tort": "A civil wrong that isn't a broken contract — someone harmed you and you can sue.",
        "Bail": "Money or conditions so you can leave jail while waiting for trial.",
        "Due Process": "Fair rules the government must follow before taking your freedom or property.",
        "Injunction": "A court order to stop doing something (or to start).",
        "Perjury": "Lying under oath — a crime because courts rely on truthful testimony.",
        "Estoppel": "You're blocked from changing your story if someone already relied on what you said.",
        "Res Judicata": "Once a case is finally decided, you usually can't sue about the same thing again."
    ]

    // MARK: - Term in Context

    static let contextScenarios: [TermContextScenario] = [
        TermContextScenario(
            id: "ctx_1",
            contextText: "In court, the witness could not appear in person. The attorney filed a sworn written statement describing what they saw that night.",
            correctTermName: "Affidavit",
            hint: "Think: written testimony under oath."
        ),
        TermContextScenario(
            id: "ctx_2",
            contextText: "Before trial, lawyers scheduled a meeting where the witness answered questions under oath while a court reporter typed every word.",
            correctTermName: "Deposition",
            hint: "Think: discovery, out of court."
        ),
        TermContextScenario(
            id: "ctx_3",
            contextText: "The committee ordered a company to produce financial records by next Friday or face contempt proceedings.",
            correctTermName: "Subpoena",
            hint: "Think: compel appearance or documents."
        ),
        TermContextScenario(
            id: "ctx_4",
            contextText: "After the grand jury indictment, the charge carried a possible sentence of more than one year in state prison.",
            correctTermName: "Felony",
            hint: "Think: serious criminal classification."
        ),
        TermContextScenario(
            id: "ctx_5",
            contextText: "The shoplifting charge was punishable by a fine and up to six months in county jail — not state prison.",
            correctTermName: "Misdemeanor",
            hint: "Think: lesser offense than a felony."
        ),
        TermContextScenario(
            id: "ctx_6",
            contextText: "The prisoner argued he was held without legal authority and asked the court to review the detention.",
            correctTermName: "Habeas Corpus",
            hint: "Think: challenge unlawful custody."
        ),
        TermContextScenario(
            id: "ctx_7",
            contextText: "The contract said the landlord could not raise a defense he had waived last year when the tenant signed the lease.",
            correctTermName: "Estoppel",
            hint: "Think: barred from contradicting prior conduct."
        ),
        TermContextScenario(
            id: "ctx_8",
            contextText: "The surgeon's failure to follow standard care caused infection. The patient sued for damages.",
            correctTermName: "Negligence",
            hint: "Think: breach of duty of care."
        ),
        TermContextScenario(
            id: "ctx_9",
            contextText: "The court ordered the factory to stop dumping waste into the river until the environmental hearing.",
            correctTermName: "Injunction",
            hint: "Think: equitable order to act or refrain."
        ),
        TermContextScenario(
            id: "ctx_10",
            contextText: "The civil rights organization was not a party to the case but filed a brief offering expertise to help the judges.",
            correctTermName: "Amicus Curiae",
            hint: "Think: friend of the court."
        )
    ]

    // MARK: - Confusion Pairs

    static let confusionPairs: [ConfusionPair] = [
        ConfusionPair(
            id: "cp_felony_misd",
            termA: "Felony",
            termB: "Misdemeanor",
            summary: "Both are crimes, but severity and punishment differ.",
            rows: [
                ConfusionRow(aspect: "Severity", termA: "Serious offense", termB: "Less serious offense"),
                ConfusionRow(aspect: "Typical penalty", termA: "Prison (often 1+ years)", termB: "Fine, probation, short jail"),
                ConfusionRow(aspect: "Long-term impact", termA: "Greater collateral consequences", termB: "Still a criminal record, usually lighter")
            ]
        ),
        ConfusionPair(
            id: "cp_habeas_mandamus",
            termA: "Habeas Corpus",
            termB: "Writ (Mandamus)",
            summary: "Both are writs, but they address different problems.",
            rows: [
                ConfusionRow(aspect: "Primary use", termA: "Challenge unlawful detention", termB: "Compel official duty (e.g. mandamus)"),
                ConfusionRow(aspect: "Who benefits", termA: "Person in custody", termB: "Party seeking action from official/court"),
                ConfusionRow(aspect: "Famous phrase", termA: "'You shall have the body'", termB: "Varies by writ type")
            ]
        ),
        ConfusionPair(
            id: "cp_affidavit_depo",
            termA: "Affidavit",
            termB: "Deposition",
            summary: "Both involve sworn facts, but format and setting differ.",
            rows: [
                ConfusionRow(aspect: "Format", termA: "Written declaration", termB: "Oral Q&A, transcribed"),
                ConfusionRow(aspect: "Setting", termA: "Prepared outside court", termB: "Discovery proceeding, often with attorneys"),
                ConfusionRow(aspect: "Typical use", termA: "Witness unavailable in person", termB: "Gather testimony before trial")
            ]
        ),
        ConfusionPair(
            id: "cp_estoppel_res",
            termA: "Estoppel",
            termB: "Res Judicata",
            summary: "Both prevent re-litigation, but from different principles.",
            rows: [
                ConfusionRow(aspect: "Basis", termA: "Reliance on prior statements/conduct", termB: "Final judgment on the merits"),
                ConfusionRow(aspect: "Scope", termA: "Often equitable, fact-specific", termB: "Same claim/parties, claim preclusion"),
                ConfusionRow(aspect: "Latin root", termA: "Stopped / prevented", termB: "A matter judged")
            ]
        ),
        ConfusionPair(
            id: "cp_plaintiff_tort",
            termA: "Plaintiff",
            termB: "Tort",
            summary: "One is a role; the other is a type of civil wrong.",
            rows: [
                ConfusionRow(aspect: "What it is", termA: "Party who brings the suit", termB: "Civil wrong (not contract breach)"),
                ConfusionRow(aspect: "Example", termA: "Injured person suing driver", termB: "Negligence causing injury"),
                ConfusionRow(aspect: "Confusion tip", termA: "Person / role", termB: "Legal category of claim")
            ]
        )
    ]

    // MARK: - Term graphs

    static let graphClusters: [TermGraphCluster] = [
        TermGraphCluster(
            id: "graph_discovery",
            title: "Discovery & Evidence",
            subtitle: "How facts are gathered before trial",
            nodes: [
                TermGraphNode(id: "n_aff", termName: "Affidavit", x: 0.2, y: 0.35),
                TermGraphNode(id: "n_dep", termName: "Deposition", x: 0.5, y: 0.2),
                TermGraphNode(id: "n_sub", termName: "Subpoena", x: 0.8, y: 0.35),
                TermGraphNode(id: "n_perj", termName: "Perjury", x: 0.5, y: 0.75)
            ],
            edges: [
                TermGraphEdge(id: "e1", fromNodeId: "n_aff", toNodeId: "n_dep", label: "written vs oral"),
                TermGraphEdge(id: "e2", fromNodeId: "n_dep", toNodeId: "n_sub", label: "compel testimony"),
                TermGraphEdge(id: "e3", fromNodeId: "n_dep", toNodeId: "n_perj", label: "oath required"),
                TermGraphEdge(id: "e4", fromNodeId: "n_aff", toNodeId: "n_perj", label: "oath required")
            ]
        ),
        TermGraphCluster(
            id: "graph_criminal",
            title: "Criminal Process",
            subtitle: "From charge to custody challenges",
            nodes: [
                TermGraphNode(id: "n_arr", termName: "Arraignment", x: 0.15, y: 0.4),
                TermGraphNode(id: "n_fel", termName: "Felony", x: 0.4, y: 0.15),
                TermGraphNode(id: "n_mis", termName: "Misdemeanor", x: 0.65, y: 0.15),
                TermGraphNode(id: "n_bail", termName: "Bail", x: 0.4, y: 0.55),
                TermGraphNode(id: "n_hab", termName: "Habeas Corpus", x: 0.85, y: 0.5)
            ],
            edges: [
                TermGraphEdge(id: "e1", fromNodeId: "n_arr", toNodeId: "n_fel", label: "charge level"),
                TermGraphEdge(id: "e2", fromNodeId: "n_arr", toNodeId: "n_mis", label: "charge level"),
                TermGraphEdge(id: "e3", fromNodeId: "n_arr", toNodeId: "n_bail", label: "pretrial release"),
                TermGraphEdge(id: "e4", fromNodeId: "n_bail", toNodeId: "n_hab", label: "custody rights")
            ]
        ),
        TermGraphCluster(
            id: "graph_writs",
            title: "Courts & Writs",
            subtitle: "Extraordinary court orders",
            nodes: [
                TermGraphNode(id: "n_writ", termName: "Writ", x: 0.5, y: 0.2),
                TermGraphNode(id: "n_hab", termName: "Habeas Corpus", x: 0.2, y: 0.65),
                TermGraphNode(id: "n_cert", termName: "Certiorari", x: 0.5, y: 0.65),
                TermGraphNode(id: "n_inj", termName: "Injunction", x: 0.8, y: 0.65)
            ],
            edges: [
                TermGraphEdge(id: "e1", fromNodeId: "n_writ", toNodeId: "n_hab", label: "type"),
                TermGraphEdge(id: "e2", fromNodeId: "n_writ", toNodeId: "n_cert", label: "type"),
                TermGraphEdge(id: "e3", fromNodeId: "n_writ", toNodeId: "n_inj", label: "equitable relief")
            ]
        )
    ]

    // MARK: - Case studies

    static let caseStudies: [CaseStudy] = [
        CaseStudy(
            id: "case_contract",
            title: "The Broken Lease",
            narrative: """
            Maya signed a one-year lease. In month four, she told the landlord she was moving out early and left. \
            The landlord had previously emailed that Maya could leave anytime without penalty. Now the landlord \
            sues for unpaid rent and tries to argue Maya must pay for the full year.
            """,
            questions: [
                CaseStudyQuestion(
                    id: "q1",
                    prompt: "Which doctrine may stop the landlord from denying the earlier promise?",
                    options: ["Estoppel", "Perjury", "Voir Dire", "Tax Lien"],
                    correctTermName: "Estoppel"
                ),
                CaseStudyQuestion(
                    id: "q2",
                    prompt: "If Maya already lost an identical rent claim last year with a final judgment, what bars a new suit?",
                    options: ["Res Judicata", "Bail", "Amicus Curiae", "Lien"],
                    correctTermName: "Res Judicata"
                ),
                CaseStudyQuestion(
                    id: "q3",
                    prompt: "Maya is the party who brought the earlier case as the injured tenant. She was the —",
                    options: ["Plaintiff", "Subpoena", "Writ", "Felony"],
                    correctTermName: "Plaintiff"
                )
            ]
        ),
        CaseStudy(
            id: "case_criminal",
            title: "Midnight Arrest",
            narrative: """
            Officers arrested Jordan at home without showing a paper authorizing entry or seizure. Jordan remains \
            in jail two weeks later. Counsel files papers asking a judge to examine whether the detention is lawful \
            and to order release if it is not.
            """,
            questions: [
                CaseStudyQuestion(
                    id: "q1",
                    prompt: "What authorization should officers usually have before searching the home?",
                    options: ["Warrant", "Deposition", "Estoppel", "Plaintiff"],
                    correctTermName: "Warrant"
                ),
                CaseStudyQuestion(
                    id: "q2",
                    prompt: "Which remedy challenges unlawful detention?",
                    options: ["Habeas Corpus", "Injunction", "Misdemeanor", "Tort"],
                    correctTermName: "Habeas Corpus"
                ),
                CaseStudyQuestion(
                    id: "q3",
                    prompt: "Jordan's first court appearance where charges are read is called —",
                    options: ["Arraignment", "Certiorari", "Quash", "Lien"],
                    correctTermName: "Arraignment"
                )
            ]
        ),
        CaseStudy(
            id: "case_discovery",
            title: "The Missing Witness",
            narrative: """
            A key witness moved abroad and cannot attend trial. The party needs sworn facts on the record and also \
            wants the other side's emails. The court sets a deadline for document production.
            """,
            questions: [
                CaseStudyQuestion(
                    id: "q1",
                    prompt: "What sworn written statement can substitute when the witness cannot appear?",
                    options: ["Affidavit", "Bail", "Felony", "Voir Dire"],
                    correctTermName: "Affidavit"
                ),
                CaseStudyQuestion(
                    id: "q2",
                    prompt: "What order compels production of emails by a deadline?",
                    options: ["Subpoena", "Negligence", "Misdemeanor", "Plaintiff"],
                    correctTermName: "Subpoena"
                ),
                CaseStudyQuestion(
                    id: "q3",
                    prompt: "If the witness were available, oral sworn testimony before trial might be taken in a —",
                    options: ["Deposition", "Arraignment", "Tax Lien", "Habeas Corpus"],
                    correctTermName: "Deposition"
                )
            ]
        )
    ]

    static func caseStudyOfTheDay(enabledPacks: Set<String>) -> CaseStudy? {
        let available = caseStudies.filter { study in
            study.questions.allSatisfy { q in
                LegalGlossary.term(named: q.correctTermName, enabledPacks: enabledPacks) != nil
            }
        }
        guard !available.isEmpty else { return nil }
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return available[day % available.count]
    }

    static func activeScenarios(enabledPacks: Set<String>) -> [TermContextScenario] {
        contextScenarios.filter { scenario in
            LegalGlossary.term(named: scenario.correctTermName, enabledPacks: enabledPacks) != nil
        }
    }
}
