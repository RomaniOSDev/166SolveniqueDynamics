import Foundation

enum LegalGlossary {
    private static let coreTerms: [LegalTerm] = [
        t("Affidavit", "A written statement confirmed by oath or affirmation.",
          "An affidavit is a voluntary written declaration of facts made under oath before a person authorized to administer oaths.",
          "The witness submitted an affidavit describing the events of the evening.",
          "Commonly used when a witness cannot appear in person.",
          .civilProcedure, related: ["Deposition", "Subpoena"]),
        t("Amicus Curiae", "A friend of the court who offers information.",
          "Amicus curiae refers to a person or organization not party to a case who provides expertise to assist the court.",
          "A civil rights group filed an amicus curiae brief supporting the petitioners.",
          "Latin phrase meaning 'friend of the court'.", .civilProcedure),
        t("Arraignment", "A court proceeding where charges are formally read.",
          "Arraignment is the formal reading of criminal charges and entry of a plea.",
          "The defendant appeared for arraignment on Monday morning.",
          "Typically one of the first steps in a criminal prosecution.", .criminalLaw, related: ["Felony", "Misdemeanor"]),
        t("Bail", "Security given to obtain release from custody.",
          "Bail is a set of pre-trial restrictions, often involving money pledged to the court.",
          "The judge set bail at ten thousand dollars.",
          "Bail may be denied for serious offenses or flight risk.", .criminalLaw, related: ["Warrant", "Arraignment"]),
        t("Burden of Proof", "The obligation to prove allegations in court.",
          "Burden of proof defines which party must establish facts and the required standard of evidence.",
          "In civil cases, the burden of proof usually rests on the plaintiff.",
          "Standards vary between civil and criminal proceedings.", .general),
        t("Certiorari", "A writ ordering review of a lower court decision.",
          "Certiorari is an extraordinary writ issued by a higher court to review a lower court decision.",
          "The Supreme Court granted certiorari to hear the appeal.",
          "Most famously used by the U.S. Supreme Court.", .civilProcedure, related: ["Writ", "Habeas Corpus"]),
        t("Deposition", "Out-of-court testimony given under oath.",
          "A deposition is sworn oral testimony reduced to writing for later use in court.",
          "Attorneys scheduled a deposition for the key witness next week.",
          "Part of the discovery phase in litigation.", .civilProcedure, related: ["Affidavit", "Subpoena"]),
        t("Due Process", "Fair treatment through the normal judicial system.",
          "Due process requires the government to respect legal rights owed to a person under the law.",
          "The defendant argued that his due process rights were violated.",
          "Protected by the Fifth and Fourteenth Amendments in the U.S.", .general),
        t("Estoppel", "A bar preventing contradictory claims or conduct.",
          "Estoppel prevents a party from asserting something contrary to prior conduct when another relied on it.",
          "The doctrine of estoppel barred the landlord from raising that defense.",
          "Includes equitable and promissory estoppel.", .contracts, related: ["Res Judicata"]),
        t("Felony", "A serious crime typically punishable by imprisonment.",
          "A felony is a criminal offense of graver character than a misdemeanor.",
          "Grand theft is classified as a felony in many jurisdictions.",
          "Classification thresholds vary by jurisdiction.", .criminalLaw, related: ["Misdemeanor", "Arraignment"]),
        t("Habeas Corpus", "A writ requiring a person to be brought before a court.",
          "Habeas corpus allows a person to seek relief from unlawful detention.",
          "The prisoner filed a petition for habeas corpus.",
          "Latin for 'you shall have the body'.", .criminalLaw, related: ["Writ", "Warrant"]),
        t("Injunction", "A court order requiring a party to do or refrain from an act.",
          "An injunction is an equitable remedy compelling or restraining specific conduct.",
          "The court issued a preliminary injunction halting construction.",
          "May be temporary or permanent.", .civilProcedure),
        t("Jurisdiction", "The authority of a court to hear and decide cases.",
          "Jurisdiction is the legal power of a court to adjudicate matters and issue binding judgments.",
          "The case was dismissed for lack of personal jurisdiction.",
          "Includes subject-matter and personal jurisdiction.", .civilProcedure),
        t("Lien", "A legal right against assets securing payment of a debt.",
          "A lien is a claim on property that must be satisfied before transfer.",
          "The contractor placed a mechanic's lien on the property.",
          "Common types include tax and mechanic's liens.", .contracts, related: ["Tax Lien"]),
        t("Misdemeanor", "A less serious criminal offense than a felony.",
          "A misdemeanor is punishable by fines, probation, or short-term imprisonment.",
          "Petty theft is often charged as a misdemeanor.",
          "Penalties vary widely by jurisdiction.", .criminalLaw, related: ["Felony"]),
        t("Negligence", "Failure to exercise reasonable care causing harm.",
          "Negligence is a tort consisting of breach of duty that proximately causes injury.",
          "The plaintiff alleged medical negligence during surgery.",
          "Requires duty, breach, causation, and damages.", .general, related: ["Tort"]),
        t("Perjury", "The offense of lying under oath.",
          "Perjury is deliberately swearing false statements after taking an oath to tell the truth.",
          "The witness was charged with perjury for false testimony.",
          "A serious criminal offense in most jurisdictions.", .criminalLaw, related: ["Affidavit", "Deposition"]),
        t("Plaintiff", "The party who initiates a civil lawsuit.",
          "The plaintiff brings a case against another seeking legal remedy for an alleged wrong.",
          "The plaintiff sought damages for breach of contract.",
          "Called the claimant in some jurisdictions.", .civilProcedure),
        t("Quash", "To annul or void a legal proceeding or order.",
          "To quash means to reject or suppress a subpoena, indictment, or warrant through a court motion.",
          "The defense moved to quash the subpoena as overly broad.",
          "Often used in discovery disputes.", .civilProcedure, related: ["Subpoena"]),
        t("Res Judicata", "A matter already judged and cannot be relitigated.",
          "Res judicata bars subsequent suits on the same claims after a final judgment on the merits.",
          "The court applied res judicata to dismiss the duplicate claim.",
          "Latin for 'a matter judged'.", .civilProcedure, related: ["Estoppel"]),
        t("Subpoena", "A writ ordering a person to appear or produce evidence.",
          "A subpoena commands testimony or production of documents at a specified time and place.",
          "The committee issued a subpoena for the financial records.",
          "Failure to comply may result in contempt charges.", .civilProcedure, related: ["Deposition", "Affidavit"]),
        t("Tort", "A civil wrong causing harm or loss.",
          "A tort is a wrongful act leading to civil liability, excluding breach of contract.",
          "The victim filed a tort claim for personal injury.",
          "Includes intentional torts and negligence.", .general, related: ["Negligence"]),
        t("Voir Dire", "Examination of prospective jurors or witnesses.",
          "Voir dire questions prospective jurors or witnesses for suitability and bias.",
          "During voir dire, attorneys questioned jurors about media exposure.",
          "French for 'to speak the truth'.", .civilProcedure),
        t("Warrant", "A court authorization for law enforcement action.",
          "A warrant authorizes police to arrest, search, or seize based on probable cause.",
          "Police obtained a search warrant for the residence.",
          "Fourth Amendment protections apply in the U.S.", .criminalLaw, related: ["Habeas Corpus"]),
        t("Writ", "A formal written order issued by a court.",
          "A writ is a written command from a court or legal authority to act or abstain from acting.",
          "The attorney filed a writ of mandamus with the appellate court.",
          "Includes habeas corpus, certiorari, and mandamus.", .civilProcedure, related: ["Certiorari", "Habeas Corpus"])
    ]

    private static let taxPackTerms: [LegalTerm] = [
        t("Tax Lien", "Government claim on property for unpaid taxes.",
          "A tax lien is a statutory lien imposed for failure to pay taxes.",
          "The IRS filed a tax lien against the property.",
          "May affect credit and property sales.", .contracts, pack: .tax, related: ["Lien", "Audit"]),
        t("Tax Audit", "Official examination of tax returns and records.",
          "A tax audit is a review of financial information to verify tax compliance.",
          "The business underwent a federal tax audit last year.",
          "Respond promptly to audit notices.", .general, pack: .tax),
        t("Tax Deduction", "Expense that reduces taxable income.",
          "A tax deduction lowers the amount of income subject to tax.",
          "Charitable contributions may qualify as a tax deduction.",
          "Rules vary by jurisdiction and filing status.", .general, pack: .tax),
        t("Withholding Tax", "Tax deducted from payments at source.",
          "Withholding tax is collected from wages or payments before the recipient receives funds.",
          "Employers remit withholding tax to the revenue authority.",
          "Common for employment and cross-border payments.", .general, pack: .tax),
        t("Capital Gains Tax", "Tax on profit from sale of assets.",
          "Capital gains tax applies to profit realized from selling investments or property.",
          "Long-term rates may differ from short-term rates.",
          "Holding period rules vary by jurisdiction.", .general, pack: .tax),
        t("Levy", "Seizure of property to satisfy a tax debt.",
          "A levy allows tax authorities to seize assets to collect unpaid taxes.",
          "The revenue agency issued a levy on the bank account.",
          "Often follows a lien and notice period.", .general, pack: .tax, related: ["Tax Lien"])
    ]

    private static let ipPackTerms: [LegalTerm] = [
        t("Copyright", "Legal right protecting original creative works.",
          "Copyright grants creators exclusive rights to reproduce, distribute, and display original works.",
          "The author registered copyright for the novel.",
          "Protection arises upon creation in many jurisdictions.", .general, pack: .intellectualProperty, related: ["Infringement"]),
        t("Patent", "Exclusive right to an invention for a limited time.",
          "A patent protects new, useful, and non-obvious inventions from unauthorized use.",
          "The company filed a patent for the medical device.",
          "Requires disclosure in the application.", .general, pack: .intellectualProperty, related: ["Licensing"]),
        t("Trademark", "Sign distinguishing goods or services of one party.",
          "A trademark protects brand names, logos, and symbols used in commerce.",
          "They registered the trademark for the product line.",
          "Can be renewed indefinitely with use.", .general, pack: .intellectualProperty),
        t("Trade Secret", "Confidential business information with economic value.",
          "Trade secrets are proprietary information kept confidential to maintain competitive advantage.",
          "The formula was protected as a trade secret.",
          "Misappropriation may lead to civil liability.", .general, pack: .intellectualProperty),
        t("Licensing Agreement", "Contract granting permission to use IP rights.",
          "A licensing agreement authorizes use of intellectual property under defined terms and royalties.",
          "The parties signed a licensing agreement for the software.",
          "Defines scope, territory, and duration.", .contracts, pack: .intellectualProperty, related: ["Patent", "Copyright"]),
        t("Infringement", "Unauthorized use of protected intellectual property.",
          "Infringement occurs when someone uses copyrighted, patented, or trademarked material without permission.",
          "The rights holder sued for trademark infringement.",
          "Remedies may include injunctions and damages.", .general, pack: .intellectualProperty, related: ["Copyright"])
    ]

    private static let familyPackTerms: [LegalTerm] = [
        t("Alimony", "Court-ordered financial support after divorce.",
          "Alimony is spousal support paid by one ex-spouse to the other following dissolution of marriage.",
          "The court awarded alimony for a period of five years.",
          "Also called spousal maintenance in some states.", .contracts, pack: .familyLaw, related: ["Child Support"]),
        t("Child Custody", "Legal responsibility for a child's care and decisions.",
          "Child custody determines where a child lives and who makes major decisions about welfare.",
          "The parents agreed to joint child custody.",
          "May be sole, joint, legal, or physical.", .general, pack: .familyLaw, related: ["Visitation Rights"]),
        t("Prenuptial Agreement", "Contract entered before marriage defining property rights.",
          "A prenuptial agreement sets terms for asset division and support if the marriage ends.",
          "They signed a prenuptial agreement before the wedding.",
          "Must meet fairness and disclosure requirements.", .contracts, pack: .familyLaw),
        t("Child Support", "Periodic payments for a child's living expenses.",
          "Child support is a court-ordered obligation to contribute to a child's financial needs.",
          "Child support payments were set according to state guidelines.",
          "Enforced through wage garnishment if necessary.", .general, pack: .familyLaw, related: ["Alimony", "Child Custody"]),
        t("Divorce Decree", "Final court order dissolving a marriage.",
          "A divorce decree is the judgment that ends a marriage and resolves related issues.",
          "The divorce decree was entered after mediation.",
          "Includes terms on property, custody, and support.", .civilProcedure, pack: .familyLaw),
        t("Visitation Rights", "Scheduled time for a non-custodial parent to see a child.",
          "Visitation rights allow a parent without primary custody to spend time with the child.",
          "The court established visitation rights every other weekend.",
          "May be supervised in certain circumstances.", .general, pack: .familyLaw, related: ["Child Custody"])
    ]

    static let allTerms: [LegalTerm] = coreTerms + taxPackTerms + ipPackTerms + familyPackTerms

    static func activeTerms(enabledPacks: Set<String>) -> [LegalTerm] {
        allTerms.filter { enabledPacks.contains($0.packId) || $0.packId == LegalTermPack.core.rawValue }
    }

    static func terms(
        in category: LegalTermCategory,
        enabledPacks: Set<String>
    ) -> [LegalTerm] {
        activeTerms(enabledPacks: enabledPacks)
            .filter { $0.category == category }
            .sorted { $0.name < $1.name }
    }

    static func term(named name: String, enabledPacks: Set<String>? = nil) -> LegalTerm? {
        let key = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let pool: [LegalTerm]
        if let enabledPacks {
            pool = activeTerms(enabledPacks: enabledPacks)
        } else {
            pool = allTerms
        }
        return pool.first {
            $0.name.lowercased() == key || $0.id == key.replacingOccurrences(of: " ", with: "_")
        }
    }

    static func relatedTerms(for source: LegalTerm, enabledPacks: Set<String>) -> [LegalTerm] {
        source.relatedTermNames.compactMap { Self.term(named: $0, enabledPacks: enabledPacks) }
    }

    static func termOfTheDay(date: Date = Date(), enabledPacks: Set<String>) -> LegalTerm? {
        let active = activeTerms(enabledPacks: enabledPacks)
        guard !active.isEmpty else { return nil }
        let day = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 0
        return active[day % active.count]
    }

    static func search(
        query: String,
        field: SearchFieldFilter = .all,
        sort: SearchSortOption = .alphabetical,
        viewCounts: [String: Int] = [:],
        category: LegalTermCategory? = nil,
        enabledPacks: Set<String>
    ) -> [LegalTerm] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let key = trimmed.lowercased()
        var results = activeTerms(enabledPacks: enabledPacks)

        if let category {
            results = results.filter { $0.category == category }
        }

        if !key.isEmpty {
            results = results.filter { term in
                switch field {
                case .all:
                    return term.name.lowercased().contains(key)
                        || term.briefDefinition.lowercased().contains(key)
                        || term.fullDefinition.lowercased().contains(key)
                        || term.usageExample.lowercased().contains(key)
                case .definition:
                    return term.fullDefinition.lowercased().contains(key)
                        || term.briefDefinition.lowercased().contains(key)
                case .example:
                    return term.usageExample.lowercased().contains(key)
                }
            }
        }

        switch sort {
        case .alphabetical:
            results.sort { $0.name < $1.name }
        case .frequency:
            results.sort {
                let left = viewCounts[$0.name] ?? 0
                let right = viewCounts[$1.name] ?? 0
                if left == right { return $0.name < $1.name }
                return left > right
            }
        }
        return results
    }

    private static func t(
        _ name: String,
        _ brief: String,
        _ full: String,
        _ example: String,
        _ notes: String,
        _ category: LegalTermCategory,
        pack: LegalTermPack = .core,
        related: [String] = []
    ) -> LegalTerm {
        LegalTerm(
            name: name,
            briefDefinition: brief,
            fullDefinition: full,
            usageExample: example,
            relatedNotes: notes,
            category: category,
            packId: pack.rawValue,
            relatedTermNames: related
        )
    }
}
