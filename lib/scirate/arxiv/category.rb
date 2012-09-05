module Arxiv

  AREA = {
    'cs' => {:name => 'Computer Science', :subs => ['cs']},
    'math' => {:name => 'Mathematics', :subs => ['math']},
    'nlin' => {:name => 'Nonlinear Sciences', :subs => ['nlin']},
    'physics' => {:name => 'Physics', :subs =>
        ['astro-ph', 'cond-mat', 'gr-qc', 'hep-ex', 'hep-lat', 'hep-ph',
         'math-ph', 'nucl-ex', 'nucl-th', 'physics', 'quant-ph']},
    'q-bio' => {:name => 'Quantitative Biology', :subs => ['q-bio']},
    'q-fin' => {:name => 'Quantitative Finance', :subs => ['q-fin']},
    'stat' => {:name => 'Statistics', :subs => ['stat']}
  }

  SUBAREA = {
    'cs' => {:name => 'Computer Science', :cats =>
        ['cs.AI', 'cs.CL', 'cs.CC', 'cs.CE', 'cs.CG', 'cs.GT', 'cs.CV', 'cs.CY',
         'cs.CR', 'cs.DS', 'cs.DB', 'cs.DL', 'cs.DM', 'cs.DC', 'cs.ET', 'cs.FL',
         'cs.GL', 'cs.GR', 'cs.AR', 'cs.HC', 'cs.IR', 'cs.IT', 'cs.LG', 'cs.LO',
         'cs.MS', 'cs.MA', 'cs.MM', 'cs.NI', 'cs.NE', 'cs.NA', 'cs.OS', 'cs.OH',
         'cs.PF', 'cs.PL', 'cs.RO', 'cs.SI', 'cs.SE', 'cs.SD', 'cs.SC',
         'cs.SY']},
    'math' => {:name => 'Mathematics', :cats =>
        ['math.AG', 'math.AT', 'math.AP', 'math.CT', 'math.CA', 'math.CO',
         'math.AC', 'math.CV', 'math.DG', 'math.DS', 'math.FA', 'math.GM',
         'math.GN', 'math.GT', 'math.GR', 'math.HO', 'math.IT', 'math.KT',
         'math.LO', 'math.MP', 'math.MG', 'math.NT', 'math.NA', 'math.OA',
         'math.OC', 'math.PR', 'math.QA', 'math.RT', 'math.RA', 'math.SP',
         'math.ST', 'math.SG']},
    'nlin' => {:name => 'Nonlinear Sciences', :cats =>
        ['nlin.AO', 'nlin.CG', 'nlin.CD', 'nlin.SI', 'nlin.PS']},
    'astro-ph' => {:name => 'Astrophysics', :cats =>
        ['astro-ph.CO', 'astro-ph.EP', 'astro-ph.GA', 'astro-ph.HE',
         'astro-ph.IM', 'astro-ph.SR']},
    'cond-mat' => {:name => 'Condensed Matter', :cats =>
        ['cond-mat.dis-nn', 'cond-mat.mtrl-sci', 'cond-mat.mes-hall',
         'cond-mat.other', 'cond-mat.quant-gas', 'cond-mat.soft',
         'cond-mat.stat-mech', 'cond-mat.str-el', 'cond-mat.supr-con']},
    'gr-qc' => {:name => 'General Relativity and Quantum Cosmology', :cats =>
        ['gr-qc']},
    'hep-ex' => {:name => 'High Energy Physics - Experiment', :cats =>
        ['hep-ex']},
    'hep-lat' => {:name => 'High Energy Physics - Lattice', :cats =>
        ['hep-lat']},
    'hep-ph' => {:name => 'High Energy Physics - Phenomenology', :cats =>
        ['hep-ph']},
    'hep-th' => {:name => 'High Energy Physics - Theory', :cats =>
        ['hep-th']},
    'math-ph' => {:name => 'Mathematical Physics', :cats =>
        ['math-ph']},
    'nucl-ex' => {:name => 'Nuclear Experiment', :cats =>
        ['nucl-ex']},
    'nucl-th' => {:name => 'Nuclear Theory', :cats =>
        ['nucl-th']},
    'physics' => {:name => 'Physics', :cats =>
        ['physics.acc-ph', 'physics.ao-ph', 'physics.atom-ph',
         'physics.atm-clus', 'physics.bio-ph', 'physics.chem-ph',
         'physics.class-ph', 'physics.comp-ph', 'physics.data-an',
         'physics.flu-dyn', 'physics.gen-ph', 'physics.geo-ph',
         'physics.hist-ph', 'physics.ins-det', 'physics.med-ph',
         'physics.optics', 'physics.ed-ph', 'physics.soc-ph',
         'physics.plasm-ph', 'physics.pop-ph', 'physics.space-ph']},
    'quant-ph' => {:name => 'Quantum Physics', :cats =>
        ['quant-ph']},
    'q-bio' => {:name => 'Quantitative Mathematics', :cats =>
        ['q-bio.BM', 'q-bio.CB', 'q-bio.GN', 'q-bio.MN', 'q-bio.NC', 'q-bio.OT',
         'q-bio.PE', 'q-bio.QM', 'q-bio.SC', 'q-bio.TO']},
    'q-fin' => {:name => 'Quantitative Finance', :cats =>
        ['q-fin.CP', 'q-fin.GN', 'q-fin.PM', 'q-fin.PR', 'q-fin.RM', 'q-fin.ST',
         'q-fin.TR']},
    'stat' => {:name => 'Statistics', :cats =>
        ['stat.AP', 'stat.CO', 'stat.ML', 'stat.ME', 'stat.OT', 'stat.TH']}
  }

  CATEGORY = {
    'cs.AI' => 'Computer Science - Artificial Intelligence',
    'cs.CL' => 'Computer Science - Computation and Language',
    'cs.CC' => 'Computer Science - Computational Complexity',
    'cs.CE' =>
        'Computer Science - Computational Engineering; Finance; and Science',
    'cs.CG' => 'Computer Science - Computational Geometry',
    'cs.GT' => 'Computer Science - Computer Science and Game Theory',
    'cs.CV' => 'Computer Science - Computer Vision and Pattern Recognition',
    'cs.CY' => 'Computer Science - Computers and Society',
    'cs.CR' => 'Computer Science - Cryptography and Security',
    'cs.DS' => 'Computer Science - Data Structures and Algorithms',
    'cs.DB' => 'Computer Science - Databases',
    'cs.DL' => 'Computer Science - Digital Libraries',
    'cs.DM' => 'Computer Science - Discrete Mathematics',
    'cs.DC' =>
        'Computer Science - Distributed; Parallel; and Cluster Computing',
    'cs.ET' => 'Computer Science - Emerging Technologies',
    'cs.FL' => 'Computer Science - Formal Languages and Automata Theory',
    'cs.GL' => 'Computer Science - General Literature',
    'cs.GR' => 'Computer Science - Graphics',
    'cs.AR' => 'Computer Science - Hardware Architecture',
    'cs.HC' => 'Computer Science - Human-Computer Interaction',
    'cs.IR' => 'Computer Science - Information Retrieval',
    'cs.IT' => 'Computer Science - Information Theory',
    'cs.LG' => 'Computer Science - Learning',
    'cs.LO' => 'Computer Science - Logic in Computer Science',
    'cs.MS' => 'Computer Science - Mathematical Software',
    'cs.MA' => 'Computer Science - Multiagent Systems',
    'cs.MM' => 'Computer Science - Multimedia',
    'cs.NI' => 'Computer Science - Networking and Internet Architecture',
    'cs.NE' => 'Computer Science - Neural and Evolutionary Computing',
    'cs.NA' => 'Computer Science - Numerical Analysis',
    'cs.OS' => 'Computer Science - Operating Systems',
    'cs.OH' => 'Computer Science - Other',
    'cs.PF' => 'Computer Science - Performance',
    'cs.PL' => 'Computer Science - Programming Languages',
    'cs.RO' => 'Computer Science - Robotics',
    'cs.SI' => 'Computer Science - Social and Information Networks',
    'cs.SE' => 'Computer Science - Software Engineering',
    'cs.SD' => 'Computer Science - Sound',
    'cs.SC' => 'Computer Science - Symbolic Computation',
    'cs.SY' => 'Computer Science - Systems and Control',
    'math.AG' => 'Mathematics - Algebraic Geometry',
    'math.AT' => 'Mathematics - Algebraic Topology',
    'math.AP' => 'Mathematics - Analysis of PDEs',
    'math.CT' => 'Mathematics - Category Theory',
    'math.CA' => 'Mathematics - Classical Analysis and ODEs',
    'math.CO' => 'Mathematics - Combinatorics',
    'math.AC' => 'Mathematics - Commutative Algebra',
    'math.CV' => 'Mathematics - Complex Variables',
    'math.DG' => 'Mathematics - Differential Geometry',
    'math.DS' => 'Mathematics - Dynamical Systems',
    'math.FA' => 'Mathematics - Functional Analysis',
    'math.GM' => 'Mathematics - General Mathematics',
    'math.GN' => 'Mathematics - General Topology',
    'math.GT' => 'Mathematics - Geometric Topology',
    'math.GR' => 'Mathematics - Group Theory',
    'math.HO' => 'Mathematics - History and Overview',
    'math.IT' => 'Mathematics - Information Theory',
    'math.KT' => 'Mathematics - K-Theory and Homology',
    'math.LO' => 'Mathematics - Logic',
    'math.MP' => 'Mathematics - Mathematical Physics',
    'math.MG' => 'Mathematics - Metric Geometry',
    'math.NT' => 'Mathematics - Number Theory',
    'math.NA' => 'Mathematics - Numerical Analysis',
    'math.OA' => 'Mathematics - Operator Algebras',
    'math.OC' => 'Mathematics - Optimization and Control',
    'math.PR' => 'Mathematics - Probability',
    'math.QA' => 'Mathematics - Quantum Algebra',
    'math.RT' => 'Mathematics - Representation Theory',
    'math.RA' => 'Mathematics - Rings and Algebras',
    'math.SP' => 'Mathematics - Spectral Theory',
    'math.ST' => 'Mathematics - Statistics',
    'math.SG' => 'Mathematics - Symplectic Geometry',
    'nlin.AO' => 'Nonlinear Sciences - Adaptation and Self-Organizing Systems',
    'nlin.CG' => 'Nonlinear Sciences - Cellular Automata and Lattice Gases',
    'nlin.CD' => 'Nonlinear Sciences - Chaotic Dynamics',
    'nlin.SI' => 'Nonlinear Sciences - Exactly Solvable and Integrable Systems',
    'nlin.PS' => 'Nonlinear Sciences - Pattern Formation and Solitons',
    'astro-ph.CO' => 'Astrophysics - Cosmology and Extragalactic Astrophysics',
    'astro-ph.EP' => 'Astrophysics - Earth and Planetary Astrophysics',
    'astro-ph.GA' => 'Astrophysics - Galaxy Astrophysics',
    'astro-ph.HE' => 'Astrophysics - High Energy Astrophysical Phenomena',
    'astro-ph.IM' =>
        'Astrophysics - Instrumentation and Methods for Astrophysics',
    'astro-ph.SR' => 'Astrophysics - Solar and Stellar Astrophysics',
    'cond-mat.dis-nn' =>
        'Condensed Matter - Disordered Systems and Neural Networks',
    'cond-mat.mtrl-sci' => 'Condensed Matter - Materials Science',
    'cond-mat.mes-hall' =>
        'Physics - Mesoscopic Systems and Quantum Hall Effect',
    'cond-mat.other' => 'Condensed Matter - Other',
    'cond-mat.quant-gas' => 'Condensed Matter - Quantum Gases',
    'cond-mat.soft' => 'Condensed Matter - Soft Condensed Matter',
    'cond-mat.stat-mech' => 'Condensed Matter - Statistical Mechanics',
    'cond-mat.str-el' => 'Condensed Matter - Strongly Correlated Electrons',
    'cond-mat.supr-con' => 'Condensed Matter - Superconductivity',
    'gr-qc' => 'General Relativity and Quantum Cosmology',
    'hep-ex' => 'High Energy Physics - Experiment',
    'hep-lat' => 'High Energy Physics - Lattice',
    'hep-ph' => 'High Energy Physics - Phenomenology',
    'hep-th' => 'High Energy Physics - Theory',
    'math-ph' => 'Mathematical Physics',
    'nucl-ex' => 'Nuclear Experiment',
    'nucl-th' => 'Nuclear Theory',
    'physics.acc-ph' => 'Physics - Accelerator Physics',
    'physics.ao-ph' => 'Physics - Atmospheric and Oceanic Physics',
    'physics.atom-ph' => 'Physics - Atomic Physics',
    'physics.atm-clus' => 'Physics - Atomic and Molecular Clusters',
    'physics.bio-ph' => 'Physics - Biological Physics',
    'physics.chem-ph' => 'Physics - Chemical Physics',
    'physics.class-ph' => 'Physics - Clasical Physics',
    'physics.comp-ph' => 'Physics - Computational Physics',
    'physics.data-an' => 'Physics - Data Analysis; Statistics and Probability',
    'physics.flu-dyn' => 'Physics - Fluid Dynamics',
    'physics.gen-ph' => 'Physics - General Physics',
    'physics.geo-ph' => 'Physics - Geophysics',
    'physics.hist-ph' => 'Physics - History of Physics',
    'physics.ins-det' => 'Physics - Instrumentation and Detectors',
    'physics.med-ph' => 'Physics - Medical Physics',
    'physics.optics' => 'Physics - Optics',
    'physics.ed-ph' => 'Physics - Physics Education',
    'physics.soc-ph' => 'Physics - Physics and Society',
    'physics.plasm-ph' => 'Physics - Plasma Physics',
    'physics.pop-ph' => 'Physics - Popular Physics',
    'physics.space-ph' => 'Physics - Space Physics',
    'quant-ph' => 'Quantum Physics',
    'q-bio.BM' => 'Quantitative Biology - Biomolecules',
    'q-bio.CB' => 'Quantitative Biology - Cell Behavior',
    'q-bio.GN' => 'Quantitative Biology - Genomics',
    'q-bio.MN' => 'Quantitative Biology - Molecular Networks',
    'q-bio.NC' => 'Quantitative Biology - Neurons and Cognition',
    'q-bio.OT' => 'Quantitative Biology - Other',
    'q-bio.PE' => 'Quantitative Biology - Populations and Evolution',
    'q-bio.QM' => 'Quantitative Biology - Quantitative Methods',
    'q-bio.SC' => 'Quantitative Biology - Subcellular Processes',
    'q-bio.TO' => 'Quantitative Biology - Tissues and Organs',
    'q-fin.CP' => 'Quantitative Finance - Computational Finance',
    'q-fin.GN' => 'Quantitative Finance - General Finance',
    'q-fin.PM' => 'Quantitative Finance - Portfolio Management',
    'q-fin.PR' => 'Quantitative Finance - Pricing of Securities',
    'q-fin.RM' => 'Quantitative Finance - Risk Management',
    'q-fin.ST' => 'Quantitative Finance - Statistical Finance',
    'q-fin.TR' => 'Quantitative Finance - Trading and Market Microstructure',
    'stat.AP' => 'Statistics - Applications',
    'stat.CO' => 'Statistics - Computation',
    'stat.ML' => 'Statistics - Machine Learning',
    'stat.ME' => 'Statistics - Methodology',
    'stat.OT' => 'Statistics - Other Statistics',
    'stat.TH' => 'Statistics - Theory'
  }

  # Prints out a list with one item per category. This is used for generating
  # the settings UI.
  def self.print_category_list_items()
    CATEGORY.each_key do |name|
      puts "              \'<li><a href=\"\#\" class=\"add-primary\"" +
           " data-cat=\"#{name}\">' +"
      puts "                '#{name} &ndash; #{CATEGORY[name]}' +"
      puts "              '</a></li>' +"
    end
  end
end

if __FILE__ == $0
  Arxiv::print_category_list_items
end
