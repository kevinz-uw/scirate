require 'test_helper'
require 'scirate/arxiv/format'


class ArxivFormatTest < ActiveSupport::TestCase

  test "only names" do
    assert_equal Arxiv::parse_authors('Anita Dabrowska'),
        [{:name => 'Anita Dabrowska'}]
    assert_equal Arxiv::parse_authors('B. Vakili and M. A. Gorji'),
        [{:name => 'B. Vakili'}, {:name => 'M. A. Gorji'}]
    assert_equal Arxiv::parse_authors(
        'P. Giannakeas, F.K. Diakonos and P. Schmelcher'),
        [{:name => 'P. Giannakeas'}, {:name => 'F.K. Diakonos'},
         {:name => 'P. Schmelcher'}]
    assert_equal Arxiv::parse_authors(
        'H-Y.Yang, A.F. Albuquerque, S. Capponi, ' +
        'A.M. Lauchli, and K.P. Schmidt'),
        [{:name => 'H-Y.Yang'}, {:name => 'A.F. Albuquerque'},
         {:name => 'S. Capponi'}, {:name => 'A.M. Lauchli'},
         {:name => 'K.P. Schmidt'}]
    assert_equal Arxiv::parse_authors(
        'Normann Mertig, Steffen L\\"ock, Arnd B\\"acker, Roland Ketzmerick, ' +
        'Akira Shudo'),
        [{:name => 'Normann Mertig'},
         {:name => 'Steffen L\\"ock'},
         {:name => 'Arnd B\\"acker'},
         {:name => 'Roland Ketzmerick'},
         {:name => 'Akira Shudo'}]
  end

  test "names and institutions" do
    assert_equal Arxiv::parse_authors(
        'Pieter Naaijkens (Radboud University Nijmegen)'),
        [{:name => 'Pieter Naaijkens',
          :institution => 'Radboud University Nijmegen'}]
    assert_equal Arxiv::parse_authors(
        'Tabish Qureshi (Centre for Theoretical Physics, J.M.I., New Delhi)'),
        [{:name => 'Tabish Qureshi',
          :institution => 'Centre for Theoretical Physics, J.M.I., New Delhi'}]
    assert_equal Arxiv::parse_authors(
        'Andrew M. Childs, John Preskill, and Joseph Renes (Caltech)'),
        [{:name => 'Andrew M. Childs'},
         {:name => 'John Preskill'},
         {:name => 'Joseph Renes', :institution => 'Caltech'}]
    assert_equal Arxiv::parse_authors(
        'Andris Ambainis (U of Latvia) and Ronald de Wolf ' +
        '(CWI and U of Amsterdam)'),
        [{:name => 'Andris Ambainis', :institution => 'U of Latvia'},
         {:name => 'Ronald de Wolf', :institution => 'CWI and U of Amsterdam'}]
    assert_equal Arxiv::parse_authors(
        'Jean-Pierre Gazeau (APC), Eric Huguet (APC), ' +
        'Marc Lachi\`eze-Rey (APC), Jacques Renaud (APC)'),
        [{:name => 'Jean-Pierre Gazeau', :institution => 'APC'},
         {:name => 'Eric Huguet', :institution => 'APC'},
         {:name => 'Marc Lachi\`eze-Rey', :institution => 'APC'},
         {:name => 'Jacques Renaud', :institution => 'APC'}]
  end

  test "numbered institutions" do
    assert_equal Arxiv::parse_authors(
        'Lieven M.K. Vandersypen (1), Isaac L. Chuang (2) ' +
        '((1) Kavli Institute of NanoScience, Delft University of Technology,' +
        ' (2) Center for Bits and Atoms & Department of Physics, ' +
        'Massachusetts Institute of Technology)'),
        [{:name => 'Lieven M.K. Vandersypen',
          :institution =>
              'Kavli Institute of NanoScience, Delft University of Technology'},
         {:name => 'Isaac L. Chuang', :institution =>
              'Center for Bits and Atoms & Department of Physics, ' +
              'Massachusetts Institute of Technology'}]
    assert_equal Arxiv::parse_authors(
        'P. Rungta (1), W. J. Munro (2), K. Nemoto (2), P. Deuar (2), ' +
        'G. J.  Milburn (2), C. M. Caves (1) ' +
        '((1) University of New Mexico, (2) University of Queensland)'),
        [{:name => 'P. Rungta',
          :institution => 'University of New Mexico'},
         {:name => 'W. J. Munro',
          :institution => 'University of Queensland'},
         {:name => 'K. Nemoto',
          :institution => 'University of Queensland'},
         {:name => 'P. Deuar',
          :institution => 'University of Queensland'},
         {:name => 'G. J.  Milburn',
          :institution => 'University of Queensland'},
         {:name => 'C. M. Caves',
          :institution => 'University of New Mexico'}]
    assert_equal Arxiv::parse_authors(
        'Domenico Giulini (1,2), Andre Gro{\ss}ardt (1,2) ' +
        '((1) ZARM - University of Bremen - Germany, (2) Institute ' +
        'for Theoretical Physics - University of Hannover - Germany)'),
        [{:name => 'Domenico Giulini',
          :institution =>
              'ZARM - University of Bremen - Germany, Institute for ' +
              'Theoretical Physics - University of Hannover - Germany'},
         {:name => 'Andre Gro{\ss}ardt',
          :institution =>
              'ZARM - University of Bremen - Germany, Institute for ' +
              'Theoretical Physics - University of Hannover - Germany'}]
    assert_equal Arxiv::parse_authors(
        'N. E. Koval (1), D. Sanchez-Portal (1 and 2), ' +
        'A. G. Borisov (3), R.  Diez Muino (1 and 2) ' +
        '((1) Centro de Fisica de Materiales CFM/MPC (CSIC-UPV/EHU), ' +
        'San Sebastian, Spain, (2) Donostia International Physics Center ' +
        'DIPC, San Sebastian, Spain, (3) Institut des Sciences Moleculaires ' +
        'd\'Orsay, ISMO, France)'),
        [{:name => 'N. E. Koval',
          :institution =>
              'Centro de Fisica de Materiales CFM/MPC (CSIC-UPV/EHU), ' +
              'San Sebastian, Spain'},
         {:name => 'D. Sanchez-Portal',
          :institution =>
              'Centro de Fisica de Materiales CFM/MPC (CSIC-UPV/EHU), ' +
              'San Sebastian, Spain, Donostia International Physics Center ' +
              'DIPC, San Sebastian, Spain'},
         {:name => 'A. G. Borisov',
          :institution =>
              'Institut des Sciences Moleculaires d\'Orsay, ISMO, France'},
         {:name => 'R.  Diez Muino',
          :institution =>
              'Centro de Fisica de Materiales CFM/MPC (CSIC-UPV/EHU), ' +
              'San Sebastian, Spain, Donostia International Physics Center ' +
              'DIPC, San Sebastian, Spain'}]
  end

  test "improperly formatted legends" do
    assert_equal Arxiv::parse_legend(
        " (1)\n   Universidade Federal de Sao Carlos, Brasil, " +
        "(2) Universidad de Guadalajara,\n Mexico, (3) Oservatorio " +
        "Astronomico di Capodimonte, Napoli, Italy "),
        { '1' => 'Universidade Federal de Sao Carlos, Brasil',
          '2' => "Universidad de Guadalajara,\n Mexico",
          '3' => 'Oservatorio Astronomico di Capodimonte, Napoli, Italy' }
    assert_equal Arxiv::parse_legend(
        " (1) Dept. of Physics, MIT, " +
        "(2)\n Dept. of Mechanical Engineering, MIT"),
        { '1' => 'Dept. of Physics, MIT',
          '2' => 'Dept. of Mechanical Engineering, MIT' }
  end
end
