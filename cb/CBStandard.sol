pragma solidity ^0.5.0;

import "../common.sol";
import "../GRSystem.sol";

/*
/// @title The reference contract of `CB` systems. Contains all data which should
/// be compared between `PreCentralBank` and `CB` creations.
*/
contract CBReferenceContract {

    /*
    /// GRS system address. In real life should look like:
    /// address public constant grsAddr = "0x1234...";
    */
    address public grsAddr;
    /*
    /// And then this definition Also should:
    /// GRS public grSystem = GRS("0x1234...");
    */
    GRS public grSystem;
    
    /*
    ///
    ////// Population accounting system
    ///
    */
    /* Adult age of given region */
    uint8 public adultAge;
    /* Minimal allowed adult age in global economy */
    uint8 public constant minAllowedAdultAge = 16;
    /* The minamal allowed age of second parent */
    uint8 public allowedSecondParentAge;
    
    /*
    ///
    ////// Tax fees accounting system;
    ///
    */
    /* % of Income tax */
    uint8 public incomeTax;
    /* Minimal allowed Income Tax in global economy */
    uint8 public constant minAllowedIncomeTax = 100; /* 10% */
    /* % of General tax */
    uint8 public generalTax;
    /* Minimal allowed General Tax in global economy */
    uint8 public constant minAllowedGeneralTax = 20; /* 2% */
    /* % of Subsidy tax */
    uint8 public subsidyTax;
    /* Minimal allowed Subsidy Tax in global economy */
    uint8 public constant minAllowedSubsidyTax = 10; /* 1% */
    /* % of Upgrade tax */
    uint8 public upgradeTax;
    /* Minimal allowed Upgrade Tax in global economy */
    uint8 public constant minAllowedUpgradeTax = 10; /* 1% */
    /* % of Extra tax */
    uint8 public extraTax;
    /* Minimal allowed Extra Tax in global economy */
    uint8 public constant minAllowedExtraTax   = 40; /* 4% */
    /* % of Contour tax */
    uint8 public contourTax;
    /* Minimal allowed Contour Tax in global economy */
    uint8 public constant minAllowedContourTax = 100; /* 10% */
    
    /*
    ///
    ////// Turnover accounting system;
    ///
    */
    /* 
    /// How many weeks in one cicle.
    /// (for loan repayment amount computation mechanism)
    */
    uint8 public cicleInWeeksForLoanRepaymentAmount;
    /* 
    /// Minimal amount of cicles.
    /// (for loan repayment amount computation mechanism)
    */
    uint8 public numberOfCiclesForLoanRepaymentAmount;
    /* 
    /// Minimal Percentage from turnover allowed to set amount of ciclical repayments.
    /// (for loan repayment amount computation mechanism).
    */
    uint8 public percentageFromTurnoverForLoanRepaymentAmount;
    /* Minimal Percentage from turnover allowed to set amount of ciclical repayments */
    uint8 public constant minAllowedPercentageFromTurnoverForLoanRepaymentAmount = 100; /* 10% */
    
    /* Returns `GRS` extension address */
    function _grsExtension(bytes4 _name) internal view returns (address) {
        address ext = grSystem.extensions(_name);
        assert(ext > address(0));
        return ext;
    }
}

/* 
/// @title Common Contract contains common construction function of 
/// `PreCentralBank` and `CB`.
*/
contract CBConstructor is CBReferenceContract {
    
    
    /* One-off function on constructor of contracts */
    function construction (
            address _grs,
            uint8 _adultAge,
            uint8 _allowedSecondParentAge,
            uint8 _incomeTax,
            uint8 _generalTax,
            uint8 _subsidyTax,
            uint8 _upgradeTax,
            uint8 _extraTax,
            uint8 _contourTax,
            uint8 _cicleInWeeksForLoanRepaymentAmount,
            uint8 _numberOfCiclesForLoanRepaymentAmount,
            uint8 _percentageFromTurnoverForLoanRepaymentAmount
        ) internal returns (bool) 
    {
        /* /* Just "one-off function" in case of `grsAddr` will be equals to 0 */
        require(grsAddr == address(0) && _grs > address(0));
        grsAddr = _grs;
        grSystem = GRS(_grs);
        /* Check Social data */
        require(
            _adultAge >= minAllowedAdultAge && _allowedSecondParentYce�^ /{faLlotgt�T��,�m." ( 4 8H){
  �(0� /:%JHekk"Tax!tIEl`�`lmek"+/:`$(    roawh2e*
0 !!0+($ �$i&cooeTap >=$milAMLowudkcoet�|`&"^gmltpCh$ax0>= minAddy��WEndr`lWeXa&&�    h"   ! �_�GnMAa��z h? K�$_gRwDxpencA|*bxpe#1#VMS&>9Igw.EALtaZLI-yx,) 0d( vf0�0(  
 #&P 0 !  $^cub�"�qap .91mi.Anl�mgSudu)gq�e� #f sgB[�dqFax08(OfenM0$l9�( `0 �0 06.
! !"   !!"` ]upgbame�`h := iinE�$o{gd�tg*`$g�ex(�&�_uqgrqde\ax >��e�drClT�z� $ $!��g0) ,d& p � �yt�i]@h >=$|ioQdlm�eMpera�X && �e~4B`\ay >"_gk.ezcm�`x0 -`�  *!h�!$"`fv(! (  ! �  Gco>uourax�F]�i�fDlf/wehK�~u/�rTry  �   1m;0  p(J .� �hlk`�I��(f�2lo�nq iccouNTmjE":i
D�`!"%rEqwlr'(�    0 �!   _k{cleYN�g�i{FirDMElRep!yma.taiO5nt * �&d WnUmjerO�Ha|dwForMoinBm1!ymefvmoq.@> < !d  b2 � � !d  $`  &&  0� `!@"   OaerBi�tewaFRoe�urk�ve�.�pMyqnaxa{od~|Hiku.|<=`.\A-|o3uD��xcM.4a}d&swMPu2now�`�o�L/dBRePiiKefu�moWft4&&("��$ $ 2,(_pM�+�ovigu"r�q��r�ntorGe2\a�Ve(axm�jpAmouN��4� grSyq�go.mc\Sr.pomT�r.ver�bcL?anRe�aio�nteoe~v1!
(�$(! ` )�
� !i�a� addH`qe! \`oQfqlu�eu;
    ( * allOwelR'bknE@a26t@ge <$_q,lowee�m�onaQa�}~tAeed( p.&1 idc�}e\ax0= _	KcGmmDax; (A!"�`,`gmneR�nTa\!}"O'engv`nTEx;J�  $  2�}jsit}4c8 ? ڳ�bShDyTah;�(` 8$ ( urgbe`fTe�"%&_}ygr�@eP��;*   (   e8vziUax $ 9 ]!~dreTax; !  (  4c�owsTAh = ^kgtk5�va|;
��!$�/��ic|%QlWmlk�VorlO1~Re8a�m�ntAmeUn� `oChklmXzW�e3DOb�m�nRDtaymu~Tlou\t;�b� �$"lum��OdC�knesFnrLoinR,!a�-%ntB�mjt #[g}m#u�O~Iiah�wFPLoaFz�xay}a�<Qm�u�P�  1�   `e>Clnpgeensom�}r�/ferDkso�oRgp!;-el\}i]nt 9�_��vseJPagqr�EdeplovervrDO!nRep�xmez�E�o�t9  0   !`p%t5bz��e%9   "o
�^/�*///" titlo `Qr�Cantel�!�n`(cOn`ra���s`�ul� `e cbraTe� fK~r�tW0sep�ta skn+Tr53TI�~ EatcJ�돀of1`G�@`cKktrcct< EFlu� vew�c�apik�Of"vhcS0codprccT �qf.c%fddrqh�uhd 
-/7"rugisu0 `JB` C}.�2qk� vibou`0`G�aITCunp alunSol@r`cp` �EetInt"�*:/Bfl|0at`PreCEotr�oB%k0a} RGo�cdSuC�o�$�
"`"0�dd2e3� pufihg`c�o)vr;
  � �"0 b�n3t"Uc^nr j*!!a`p0	$` , sduxeS�)[grc<
    ! $"`  �uant _alulUAce,@   "4$ pf 5m~U8!ahljweFse+mnePa-m4aw�,�1    9!  (bu{fd�0SmocomeTax,!""��  d b  !int Wwt.l�glQax, �!    �j !�uhnt40_s}bsyd=Tsx<
0  !�0 d(" uknt {u`g�aeeeai,
"    i!@ �0(emo08`w�xu�aD)x
!�!0�  "!   u�nty _coNto��Daxd   )$  �  1�U��9 ^C[cL��nW}�k�Fk:��`&Teq`8medtUlgukv<
$    "5�"`$U)nt8nwber_fCmc|%s"o2,o`�Vup�mongI,Wunt� !  �"  "`� uit _pezkc>TagenroM@upfovmrFNroinRep@yo%f$E�oul4
`� "d(� 0eblhc
 (!bk�  !+   asqer�(8    !    )%s�Nct3gCtikn(_oss. �qdUltGe, s'dmow�tS%c.nTRazendQge$
    (  (     BTK~smmeTB�l _eenf�be0,`^s5bs�yVe9,`^dpgaalmT�x,
h  �    `#    $`�u�p�bVax$_#o�tg%rUaZ<"_Cigd`InWue�sFornqzpmrapmmmtI}lUvt$%82�"�$0    *  _�UejevObAhg�esDor�wanup�}-ef4Eouft,a_Re2#Mnv!ge2jmTY�n/VmrFPLoe.[mp`{mcn�Ao{}t9
�0 P �(';� !!) $ ��baavn� =,mqw<CmntaRs
p "}}
�:
/&.&@~itl I2ah�n#e!Stendpc� � CenUriL�BeN�0�knt0`Cd*6jon4�aCd AB$is2COBg~wT�uwTjҠ{
 �$ /+!v'r7mon �f�h�b`"cnf|ract"
g
  �2e`.tr56 p}Bli��C�n�ra�,Vk~shon3��00!/h�Qddr%s�$/& nd�FB"if `l>$}nct��n� �ELLgatEc to"+'
""  adlre7s`hujlm(4�he�atdTo;a@(/*"�ddr%Q�`o&�koBuouR`�ug)onEl0cWr5mu�6icY@Ggt|R!kpd'� 0 $``dre�zdpu{lyq Jmntorcg~|s�c|
    �
$`B$@`eye�o)ols%�b�`|%d"ny00�buKcip`ntp gf �agi�.sd`�s'ngeq �J    }qpp�no (by�mS+2`3� jdhrews) �<�Nic�gbExtmnCimn{;
 % 
 !� �*
 0 /-/� � 0+/?k��2`SBd `EDPxg`�mmd�ldq$cent"od 3yste�  a(///+�` "/
   $o"�eAtdbis� ov acti�e�`#C@(ievhn$s"*?�  $-ap��f'``$seRY9> jklh)H2V2��b(agt��5kBMe$hoqr�  $ '*
"p&$7	 D!t�f1�% m� MEtcjds c�eadaDdby�r�r�Ac�hantb*�� rEion�(�GKo~g�x!
("(�'�+(!c@`(LM'4@jdSz%win,0in7e|q!t q	�) `�b` tExtejCo~`q o~My `qf�x�e.;9mnsb).
  ` (/
$"" ia\ting`byt5s#r"5? qdeSm{s	 u5�las*bbMd$h�d�J   !J�0�0*� #�$//  $1/////+ Pop}datiif aacoPkTkND qnwtd-� ! $��*�D 1
/
(D  /*4�agy/naL$qwp}�a4i�n�lf!cNOm�a Wystee *m* 0 �emnt3u6h�tFLhc VwtalPo�eL�$]gg;+ $ 
 $� /*(rewio.ah`seeklm$Akccult)neov0*U%a>"n�/- dfmtine3 `credagl raGks�rqpio^ */   1-k@x\,N jnT2uv ]> uM*535�j8�ublMc gef/l9@Umkn�e�isTraMi=.?*  ;�Re�inNcl �oN}%l `c#m5ltiN�0mchjw9iN0from �r�v�Otr* gvA���i reok�Tpau�nn��/� �$�myPi)~w (uI�t047b�~�u)nt�528�p�D~�g #nbUa|Iu�anJeg)�tVa��iz� 1 (.2  �>+ Rg�i�na|$aGcOun\(le gfcmRth"x%rPwe�j*/+` `$eapry.G8(�int4u6`=>�=iEv1%�	$ttkli�3Ee;LiB�rtxAcco�.tj�&+J"`  -� Ro�Io~��Aakou^v�ng&o.�cif`X q�R �%`vH"'*$( 0mae`in�$a!.|2�56 uiop�%	 p5jlhc n.ualB)2wh@scou.|ija
� (/+�Re'i+fin`a.U!n0jil�oicAo`m�6l%rs qg�(iBk'5npinw +.!  #Mxt��o�	qiNd8%v 7>%�"jp21wK�s^)(�wbui'4�xn}amo��h�vsAcMAcCotn�an{  ��+*��gmoNal"annt�l biol)ghc!� �at��r{ ece�aa:o1nT)�#`j,  �$m!pQiz' went2`=.0tijtR%>Yv2�+ tubhkc a~nual����wp3I�uSgcM�nting' q�� �  o*`R$wkonaa"i`g~gltA~q f$mob4 ,�t� per cdek!b?
 �` mGxpafg8�uhNv256 =. �iNT;�>� }�Blka v%e+hyMk�fra�MvZACCgunuhjc?�d� "c* �e�i�f%l a�"un}i.g"ofhhOev�ly�u tis{%az */$!(m�pr�nG$(5Int>57"=>$uio�256) xU�lK @fneatD]`|rAlh$9ccoT~ui>m:,)  (�`a`/*(`eghOoal0ag�v�~vh*'2G�!mgr$ahJdy mGu:)0es*yearh*-1  miptk�g�	p}ltr6h:6 ihG556^2"_9`wb(i�&�nlu!hM]2gv!l#ty@'e�A#c�Uld�ng;$$$o�@Rgg-/nel `njUl `we a'mUntq�w *�J    oI0pmlg"(ei.T2<� 4>��int356[:7M/$p%BL��0`~n}(|0yV%z3CofC#Cke�tiff/�  "�  �*!R`gaoOal avm%!| aa�Oufvi�o�nf s)Ckjl eveS!hyl`d�yS :�.0 !ma�pang �uint�q> 96$uin1">) p�bd�c mfn�0i�kco}~thf%OfS�C{Le`vas
D  (J  ! ): Rq&i.nil1aeekls!c#co5nT)>g��g ak#idl tS�(}o`|je ~wiber$og ccs%� �eq Hwlan)"aresnri!/
�`p%qpY�'1�u(nt456 =>#uint256) 2u�haC w���lyAcbka��ijgd���ifa/peDWoro�
�(  k+ REg	/nal anntad !BcOuntan' nf sc�dgnu3`.k~d��� }umc}2 &��A3a�PbY2dRh}mi
) aT@5mrk�*� )�$mAd`hng!)�iNw2u5 =� q`n�3�6ip1bl�j(a�,�ilAcBeufvkngfIkkife�tsC1uN^{3  (b  !4+*bReci%~eX �-uk�y !c"ouoLaNg m&%aAChdE�tS!,ij�|he"~q}bep o sc{us`tej*h|mqn) 
+�!4 |atd)~�  qiov2=6 =�@uif5256 p="li#!WdekMY�c#/Sjt�ngOfQcb�%o�ts;
4�@"."rwg	oo%l bO|ual�qc�o5�Yt'kf �/gi'a~tr�(�~0the.�/b%j"of �gsds pev hqma.I("+�($*mk�ping,uiet2> =<0u�otr56i pyc|IC #o.} lAkcoufpMocNg�ch�mnpv3  &0* 0 $7*$A,|ua| asrow�tan5 knjo�2ql!ass��elpc ()n�Tzg"o5|b-{to& c`se#p!r`Humax)�A� wk��!*'*  (`iatqhg�{imt"1f"<>(]mNt6p6Izublic$av��qmacro�.ti&gof2�a��cCidcnt7Ammng�'(   �* �~.5al a cbwnTpng�n� m/2sad0ac#lt%��s!*ij t``cnq�bgx�n' c�qes tab hu�a�) */ (  -a��i�0 umnt376 =4 u�.�256ipbU"t�u`l,wa�cm�u&uhneOb�+2f`lAci$gm0q�J0 $"+���ac�Eltinc�oF"toua, ireiL`assm`unt3 h)N4�hg nUe`ub$n` g sDs$rdvh5mam� �/
$4 �u�lt256 |qfjia Tk!oE�dAn�b`aEe~ts: !(��P!"?*$bu~hojcm)alNga| a_"oW~@i,w"ow(�veR}c�({ng`u�pesua.rY *g 4!`!�apPy�' )uCn4216 n2�iVt8)"0uBLiq$h4eZagMkfe�xpekpAbc{+
��� 
� � �
 @|d!ct�e jrAowR@s mf regign k�	�`  }aPPkff(8adlress$5>"bmmL) r�rlic i�tiv}drivi2s" ��/*`ln GEyfu`mrAni:apy��sBol�raeh/n!+/ "b`mar�i*#"had�res�$; `K�m�P%"�iø�cthfEW�tiviar;: �h�'* ald"aapkS)�+�sd/n zCciN */
$" !iA�9yfg d$r%�s ?� bkgl-�tuj�Ic al(�"ti{Hti�a�
�d "o( At|*Lasm B{m`��y �a�uw$rfgi;Tg�  )
"$" }a@4ifg+gYtE32`<< `mol!$quj|Yc loK`�compynyN)}]s�*�  0�(@RnN�L{b1d#AOmxa/i�qDdrm��`ref{sdn�`g�m~$b� ~+e�j/� �0<|apping 8bxtgS3& %;jaFdbwcR+ P}b�ie"so�0an+A�`RdrsBy�c�m:  ! (  `+"J0 ``n'?
 0 ��?//o. V!y�reEq!cccjul�a.g`cyste�3J8b` ?/
( *�
  8 &*�iwr`ti?�dtaxMn!E|he2�)/` $ 5�f�47 `ubmicqli�RatIonVax�
�! '*"Em�gsG6-on$d�|0in 4ler!j�   u}ct"5? PuK�k  e`m�`t�o�Ax	:!,  /9"
!  @/o$cx%+ �(&r/-�-hsp*k& type{ �}z aaCh�`CKmpaJyp. *d *<
$$4 oa�Pjnu!(�dtrEwS �<&qinT8(0pt"nmc %~�ktie�\aTes;""� /*�ircmef4�n�`d �nn|a| Inyi% }ay fe-s`fgp`Ca�j �DpcfeP` (/
  80ieppinc x�i�t5�,7<(IapQing$hcd$rmS�5}� W�n�v}6	/!@nnuplIncomg\ix3J $` ?.�AccO.t)fg(oF W%eOv� 	.comi qeY vf%wdo{ }`el4@T9iv}r`0+>
�   )erP�OC`�TinT255(=; /apXan%�(`e`rd?s5:�uin`p-�))$0eeILOnc�mwTax5���0 $  /*!Qcem�{u�NgofDajnea< d�`~a` piy`$e�s &rOm`m#Ch �zoif�zbvym�#*p(� ap0iNn$(tymt�,�5 Oapi.f!*affbmsK8<>(Ein625~1� ajrea.GefDrgM\sx;    /*�Accn��i>g!o� �@ekh�g!oEr�l(4ax!famc fro] %ag0�orgaoihqVioj$*/
 " 6oapu)fg (tajl"� �> /�0pine (i`�R�S{ �> q	><2%v )e!i-kOendre|V`|;* "#'J   /ja'o_q~6K.G _g0bon}c��Swvs}D}%t�p�f��BHB3om DaZyOrgAf�zith/n"*-
  �&e� ping` 5.Ur5V"�> ?Apbi�gapdr52r => ��nt�e)m `nntCmS�Csi$aPip:
�`  =*�Ac�gunu)ogo&`}eendx S}b3ity!|�tdeas rrMiagAI@OZgc&aza5ign�	'
 ! �map ng!(ul>tr16`=>!}�pPing "cdd�uss"8>8u�N4:5$))$ge%nyu��id�Uax;
    
    /* Accounting of annual Upgrade tax fees from each organization */
    mapping (uint256 => mapping (address => uint256)) annualUpgradeTax;
    /* Accounting of weekly Upgrade tax fees from each organization */
    mapping (uint256 => mapping (address => uint256)) weeklyUpgradeTax;
    
    /* Accounting of annual Extra tax fees from each organization */
    mapping (uint256 => mapping (address => uint256)) annualExtraTax;
    /* Accounting of weekly Extra tax fees from each organization */
    mapping (uint256 => mapping (address => uint256)) weeklyExtraTax;
    
    /* The boolean of migration process of any `Driver`. If true, migration in process */
    mapping (address => bool) public migrationTaxPaid;
    
    /* The boolean of emigration process of any `Driver`. If true, emigration finished */
    mapping (address => bool) public emigrationTaxPaid;
    
    /*
    ///
    ////// Turnover accounting system;
    ///
    */
    /* Amounts of annual turnovers for each organization. */
    mapping (uint256 => mapping (address => uint256)) annualTurnovers;
    /* Amounts of weekly turnovers for each organization.*/
    mapping (uint256 => mapping (address => uint256)) weeklyTurnovers;
    /* Total annual turnover of all organizations */
    mapping (uint256 => uint256) public totalAnnualTurnovers;
    /* Total weekly turnover of all organizations */
    mapping (uint256 => uint256) public totalWeeklyTurnovers;
    
    /* Allowance to call only for active `GRS` `Method`s */
    modifier onlyByActiveMethod() {
        require(grSystem.activeMethods(msg.sender));
            _;
    }
    
    /* Allowance to GET only by trusted senders */
    modifier getByTrusted(address _sender) {
        require(grSystem.activeMethods(msg.sender) || msg.sender == _sender);
            _;
    }
    
    /* Allowance to call only by active entities */
    modifier onlyForEntities(address _entity) {
        require(activeEntities[_entity]);
            _;
    }
    
    /* Allowance to call only by active drivers */
    modifier onlyForActiveDriver(address _driver) {
        require(DMS(_grsExtension(bytes4("DMS"))).activeDrivers(_driver));
            _;
    }
    
    /* Allowance to execute inly if `CB` is active */
    modifier onlyAtActiveCB() {
        assert(delegatedTo == address(0));
            _;
    }
    
    /* Check given week number not more than current and more than zero */
    modifier checkWeek(uint256 _weekn) {
        require(_weekn <= _week() && _weekn > 0);
            _;
    }
    
    /* Check given year number not more than current and more than system registered at */
    modifier checkYear(uint256 _yearn) {
        require(_yearn <= _year() && _yearn >= grSystem.registrationYear());
            _;
    }
    
    constructor (
            address _grs,
            uint8 _adultAge,
            uint8 _allowedSecondParentAge,
            uint8 _incomeTax,
            uint8 _generalTax,
            uint8 _subsidyTax,
            uint8 _upgradeTax,
            uint8 _extraTax,
            uint8 _contourTax,
            uint8 _cicleInWeeksForLoanRepaymentAmount,
            uint8 _numberOfCiclesForLoanRepaymentAmount,
            uint8 _percentageFromTurnoverForLoanRepaymentAmount,
            uint256 _version
        ) public 
    {
        assert(
            construction(_grs, _adultAge, _allowedSecondParentAge, _incomeTax, _generalTax, 
                _subsidyTax, _upgradeTax, _extraTax, _contourTax, _cicleInWeeksForLoanRepaymentAmount,
                _numberOfCiclesForLoanRepaymentAmount, _percentageFromTurnoverForLoanRepaymentAmount)
        );
        require(_version > 0);
        contractVersion = _version;
    }
    
    /*
    ///
    ////// `CB` internal functions
    ///
    */
    /* Current global year */
    function _year() internal view returns (uint256) {
        return grSystem.year();
    }
    
    /* Current global week */
    function _week() internal view returns (uint256) {
        return grSystem.week();
    }
    
    /* Returns `Operator` contract */
    function _operator() internal view returns (Operator) {
        return grSystem.operator();
    }
    
    /*
    ///
    ////// `CB` external functions for use only by trusted subjects
    ///
    */
    /*
    /// @notice The universal "make" function of `CB`.
    /// Allowed to call just from active `GRS` `Method`.
    /// @param _name The name of `Method`.
    /// @param _subject The subject `Method` operates with.
    */
    function make(bytes32 _name, address _object)
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool) 
    {
        return grSystem.make(_name, _object);
    }
    
    /*
    /// @notice The universal "get" function of `CB`.
    /// Allowed to call just from active `GRS` `Method`.
    /// @param _name The name of `Method`.
    /// @param _subject[] The subject(s) `Method` operates with.
    */
    function get(bytes32 _name, address _object)
        onlyAtActiveCB
        onlyByActiveMethod
        external view returns (uint256) 
    {
        return grSystem.get(_name, _object);
    }
    
    /*
    ///
    ////// `CB` external functions for use only by `GRS` `Method`s
    ///
    */
    
    /*
    /// @notice The basis of delegation `CB` functions to the new `CB` contract.
    /// Allowed to call just from active GRS `Method`.
    /// @param _cb Address of new `CB`.
    */
    function delegateToCB(address _cb)
    /*
    /// At this moment lets leave this functioning at deactivated `CB` to. 
    /// It gives an opportunity to delegate in unification processes of regions.
    */
        //onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        require(CBMS(_grsExtension(bytes4("CBMS"))).allCentralBanks(_cb));
        delegatedTo = _cb;
        return true;
    }
    
    /*
    /// @notice The basis of definition of `Contour` contract address.
    /// Allowed to call just from active GRS `Method`.
    /// @param _contour Address of Regional `Contour` contract.
    */
    function setContourContract(address _contour)
        onlyByActiveMethod
        external returns (bool)
    {
        require(_contour > address(0));
        assert(contourContract == address(0));
        contourContract = _contour;
        return true;
    }
    
    /*
    /// @notice The basis of definition of `CB` `Extension` contract.
    /// Allowed to call just from active GRS `Method`.
    /// @param _name The name of `Extension`.
    /// @param _extension The address of `Extension`.
    */
    function setCBExtension(bytes32 _name, address _extension)
        onlyByActiveMethod
        external returns (bool)
    {
            require(cbExtensions[_name] == address(0));
            require(_extension > address(0));
            cbExtensions[_name] = _extension;
            return true;
    }
    
    /*
    /// @notice The basis of deactivation of `CB` `Method` contract.
    /// Allowed to call just from active GRS `Method`.
    /// @param _name The name of `Method`.
    */
    function deactivateCBMethod(bytes32 _name)
        onlyByActiveMethod
        external returns (bool)
    {
        require(cbExtensions[_name] > address(0));
        activeCBMethods[cbExtensions[_name]] = false;
        return true;
    }
    
    /*
    /// @notice The basis of activation of `CB` `Method` contract.
    /// Allowed to call just from active GRS `Method`.
    /// @param _name The name of `Method`.
    */
    function activateCBMethod(bytes32 _name)
        onlyByActiveMethod
        external returns (bool)
    {
        require(cbExtensions[_name] > address(0));
        activeCBMethods[cbExtensions[_name]] = true;
        return true;
    }
    
    /*
    /// @notice The basis of definition of `CB` `Method` contract.
    /// Allowed to call just from active GRS `Method`.
    /// @param _name The name of `Method`.
    /// @param _method The address of `Method`.
    */
    function setCBMethod(bytes32 _name, address _method)
        onlyByActiveMethod
        external returns (bool)
    {
        require(_name.length > 0);
        require(_method > address(0));
        activeCBMethods[cbMethods[_name]] = false;
        cbMethods[_name] = _method;
        activeCBMethods[cbMethods[_name]] = true;
        return true;
    }
    
    /*
    /// @notice The basis of definition of adult age of region.
    /// Allowed to call just from active GRS `Method`.
    /// Age should be more than 15 years old.
    /// @param _age Age when parson starts to be adult.
    */
    function setAdultAge(uint8 _age)
        onlyByActiveMethod
        external returns (bool)
    {
        assert(_age >= minAllowedAdultAge);
        adultAge = _age;
        return true;
    }
    
    /*
    /// @notice The basis of definition of allowed second parent age.
    /// To register at children `Driver` contract side to get 
    /// permissions to manage children contract.
    /// Allowed to call just from active GRS `Method`.
    /// @param _age Minimal age of parent.
    */
    function setAllowedSecondParentAge(uint8 _age)
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        require(_age >= minAllowedAdultAge);
        require(_age <= 20);
        allowedSecondParentAge = _age;
        return true;
    }
    
    /*
    /// @notice The basis of increment of number of "citizen".
    /// In case of migration from other regions.
    /// Allowed to call just from active GRS `Method`.
    */
    function addToTotalPopulation()
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        totalPopulation += 1;
        return true;
    }
    
    /*
    /// @notice The basis of decrement of number of "citizen".
    /// In case of emigration to other region.
    /// Allowed to call just from active GRS `Method`.
    */
    function decreaseFromTotalPopulation()
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        totalPopulation -= 1;
        return true;
    }
    
    /*
    /// @notice The basis of increment annual, weekly human registration 
    /// and total population.
    /// In case of computation of Human registration accounting.
    /// Allowed to call just from active GRS `Method`.
    */
    function addToHumanRegistration()
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        weeklyHumanRegistration[_week()] += 1;
        annualHumanRegistration[_year()] += 1;
        totalPopulation += 1;
        return true;
    }
    
    /*
    /// @notice The basis of increment annual, weekly births and total population.
    /// In case of computation of birth accounting.
    /// Allowed to call just from active GRS `Method`.
    */
    function addToBirthAccounting(uint8 _motherIndex, uint8 _fatherIndex)
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        require(_motherIndex < 22 && _fatherIndex < 22);
        weeklyBirthAccounting[_week()] += 1;
        annualBirthAccounting[_year()] += 1;
        annualMothersAgeAccounting[_year()][_motherIndex] += 1;
        annualFathersAgeAccounting[_year()][_fatherIndex] += 1;
        totalPopulation += 1;
        return true;
    }
    
    /*
    /// @notice The basis of increment annual, weekly mortalities
    /// and decrement total population.
    /// In case of computation of mortality accounting.
    /// Allowed to call just from active GRS `Method`.
    */
    function addToMortalityAccounting(uint8 _index)
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        require(_index < 22);
        weeklyMortralityAccounting[_week()] += 1;
        annualMortralityAccounting[_year()] += 1;
        annualMortralityAgesAccounting[_year()][_index] += 1;
        totalPopulation -= 1;
        return true;
    }
    
    /*
    /// @notice The basis of increment annual age accountings.
    /// Allowed to call just from active GRS `Method`.
    /// First need to be registrated at the `CB` contract and then at the 
    /// `GRS` `Extension` (!!!)
    /// @param _driver Address of active `Driver` contract.
    /// @param _cb Address of active `CB` contract.
    /// @param _index Index in list of 5 year groups.
    */
    function addToAgeAccounting(address _driver, uint8 _index)
        onlyByActiveMethod
        onlyForActiveDriver(_driver)
        external returns (bool)
    {
        if (DMS(_grsExtension("DMS")).annualAgeRegistration(_year(), _driver))
            return true;
        require(_index < 22);
        annualDriversAgeAccounting[_year()][_index] += 1;
        return true;
    }
    
    /*
    /// @notice The basis of increment annual sick leaves.
    /// Allowed to call just from active GRS `Method`.
    /// @param _days Number of days for each case.
    */
    function addToSickLeaves(uint256 _days)
        onlyByActiveMethod
        external returns (bool)
    {
        require(_days > 0);
        annualAccountingOfSickLeaves[_year()] += _days;
        return true;
    }
    
    /*
    /// @notice The basis of increment Accident.
    /// Allowed to call just from active GRS `Method`.
    */
    function addToAccidentsAtWork()
        onlyByActiveMethod
        external returns (bool)
    {
        weeklyAccountingOfAccidentsAtWork[_week()] += 1;
        annualAccountingOfAccidentsAtWork[_year()] += 1;
        return true;
    }
    
    /*
    /// @notice The basis of increment Accident.
    /// Allowed to call just from active GRS `Method`.
    */
    function addToAccidents()
        onlyByActiveMethod
        external returns (bool)
    {
        weeklyAccountingOfAccidents[_week()] += 1;
        annualAccountingOfAccidents[_year()] += 1;
        return true;
    }
    
    /*
    /// @notice The basis of increment mortal Accident at work.
    /// Allowed to call just from active GRS `Method`.
    */
    function addToMortalAccidentsAtWork()
        onlyByActiveMethod
        external returns (bool)
    {
        annualAccountingOfMortalAccidentsAtWork[_year()] += 1;
        totalMortalAccidents += 1;
        return true;
    }
    
    /*
    /// @notice The basis of increment mortal Accident.
    /// Allowed to call just from active GRS `Method`.
    */
    function addToMortalAccidents()
        onlyByActiveMethod
        external returns (bool)
    {
        annualAccountingOfMortalAccidents[_year()] += 1;
        totalMortalAccidents += 1;
        return true;
    }
    
    /*
    /// @notice The basis of definition of average life expectancy.
    /// In case of computation of birth and mortality accounting.
    /// Allowed to call just from active GRS `Method`.
    /// @param _avLExp The average life expectancy.
    */
    function setAverageLifeExpectancy(uint8 _expectancy)
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        require(_expectancy > 0);
        averageLifeExpectancy[_year()] = _expectancy;
        return true;
    }
    
    /*
    /// @notice The basis of `Driver` activation by medical structure,
    /// or in case of migration process.
    /// Allowed to call just from active GRS `Method`.
    /// @param _driver Address of `Driver` contract.
    */
    function activateDriver(address _driver)
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        require(DMS(_grsExtension(bytes4("DMS"))).allDrivers(_driver));
        activeDrivers[_driver] = true;
        allActivities[_driver] = true;
        return true;
    }
    
    /*
    /// @notice The basis of `Driver` deactivation by medical structure,
    /// or in case of emigration process.
    /// Allowed to call just from active GRS `Method`.
    /// @param _driver Address of `Driver` contract.
    */
    function deactivateDriver(address _driver)
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        require(DMS(_grsExtension(bytes4("DMS"))).allDrivers(_driver));
        activeDrivers[_driver] = false;
        allActivities[_driver] = false;
        return true;
    }
    
    /*
    /// @notice The basis of any entity activation.
    /// (also `Driver` as business entity).
    /// Allowed to call just from active GRS `Method`.
    /// @param _entity Address of any entity contract.
    */
    function activateEntity(address _entity)
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {  
        require(
            CMS(_grsExtension(bytes4("CMS"))).allCompanies(_entity) ||
            BOMS(_grsExtension(bytes4("BOMS"))).allBudgetOrgs(_entity)
        );
        activeEntities[_entity] = true;
        allActivities[_entity] = true;
        return true;
    }
    
    /*
    /// @notice The basis of any entity deactivation.
    /// (also `Driver` as business entity).
    /// Allowed to call just from active GRS `Method`.
    /// @param _entity Address of any entity contract.
    */
    function deactivateEntity(address _entity)
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {  
        require(
            CMS(_grsExtension(bytes4("CMS"))).allCompanies(_entity) ||
            BOMS(_grsExtension(bytes4("BOMS"))).allBudgetOrgs(_entity)
        );
        activeEntities[_entity] = false;
        allActivities[_entity] = false;
        return true;
    }
    
    /*
    /// @notice The basis of any `Company` assignation to the names register.
    /// Allowed to call just from active GRS `Method`.
    /// @param _name Unique Name of any entity contract.
    /// @param _entity Address of entity contract.
    */
    function addToLocalCompanyNames(bytes32 _name, address _entity)
        onlyAtActiveCB
        onlyForEntities(_entity)
        onlyByActiveMethod
        external returns (bool)
    {
        assert(!localCompanyNames[_name]);
        localCompanyNames[_name] = true;
        companyAddressByName[_name] = _entity;
        return true;
    }
    
    /*
    /// @notice The basis of any `Company` deassignation on the names register.
    /// Allowed to call just from active GRS `Method`.
    /// @param _name Unique Name of any entity contract.
    */
    function removeFromLocalCompanyNames(bytes32 _name)
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        assert(localCompanyNames[_name]);
        localCompanyNames[_name] = false;
        companyAddressByName[_name] = address(0);
        return true;
    }
    
    /*
    /// @notice The basis of definition of Income Tax amount.
    /// Allowed to call just from active GRS `Method`.
    /// @param _tax Percentage of Income Tax.
    */
    function setIncomeTax(uint8 _tax)
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        require(_tax > 0);
        incomeTax = _tax;
        return true;
    }
    
    /*
    /// @notice The basis of definition of General Tax amount.
    /// Allowed to call just from active GRS `Method`.
    /// @param _tax Percentage of General Tax.
    */
    function setGeneralTax(uint8 _tax)
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        require(_tax > 0);
        generalTax = _tax;
        return true;
    }
    
    /*
    /// @notice The basis of definition of Subsidy Tax amount.
    /// Allowed to call just from active GRS `Method`.
    /// @param _tax Percentage of Subsidy Tax.
    */
    function setSubsidyTax(uint8 _tax)
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        require(_tax > 0);
        require(_tax < generalTax);
        subsidyTax = _tax;
        return true;
    }
    
    /*
    /// @notice The basis of definition of Upgrade Tax amount.
    /// Allowed to call just from active GRS `Method`.
    /// @param _tax Percentage of Upgrade Tax.
    */
    function setUpgradeTax(uint8 _tax)
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        require(_tax > 0);
        require(_tax < generalTax);
        upgradeTax = _tax;
        return true;
    }
    
    /*
    /// @notice The basis of definition of Extra Tax amount.
    /// Allowed to call just from active GRS `Method`.
    /// @param _tax Percentage of Extra Tax.
    */
    function setExtraTax(uint8 _tax)
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        require(_tax > 0);
        require(_tax > generalTax);
        extraTax = _tax;
        return true;
    }
    
    /*
    /// @notice The basis of definition of Contour Tax amount.
    /// Allowed to call just from active GRS `Method`.
    /// @param _tax Percentage of Contour Tax.
    */
    function setContourTax(uint8 _tax)
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        require(_tax > 0);
        contourTax = _tax;
        return true;
    }
    
    /*
    /// @notice The basis of definition of Migration Tax amount.
    /// Allowed to call just from active GRS `Method`.
    /// @param _tax Amount of Migration Tax.
    */
    function setMigrationTax(uint256 _tax)
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        require(_tax > 0);
        migrationTax = _tax;
        return true;
    }
    
    /*
    /// @notice The basis of definition of Emigration Tax amount.
    /// Allowed to call just from active GRS `Method`.
    /// @param _tax Amount of Emigration Tax.
    */
    function setEmigrationTax(uint256 _tax)
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        require(_tax > 0);
        emigrationTax = _tax;
        return true;
    }
    
    /*
    /// @notice The basis of definition of Tax amount for any entity.
    /// Allowed to call just from active GRS `Method`.
    /// @param _entity Address of any entity.
    /// @param _tax Amount of Tax.
    */
    function setEntityTax(address _entity, uint8 _tax)
        onlyAtActiveCB
        onlyByActiveMethod
        onlyForEntities(_entity)
        external returns (bool)
    {
        require(_tax > 0);
        entitiesTaxes[_entity] = _tax;
        return true;
    }
    
    /*
    /// @notice The basis of addition of Income Tax payment of any `Driver`.
    /// Addition is fixing at all levels of database needed.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed to add only for `Driver` contract.
    /// @param _driver Address of any `Driver`.
    /// @param _amount Amount of Tax.
    */
    function addPaymentOfIncomeTax(address _driver, uint256 _amount)
        onlyAtActiveCB
        onlyByActiveMethod
        onlyForActiveDriver(_driver)
        external returns (bool)
    {
        require(_amount > 0);
        uint year = _year();
        uint week = _week();
        annualIncomeTax[year][_driver] += _amount;
        weeklyIncomeTax[week][_driver] += _amount;
        return true;
    }
    
    /*
    /// @notice Gets the total amount of annual Income Tax payments of any `Driver`.
    /// Allowed to call just from active GRS `Method` or `Driver` contract owner.
    /// @param _yearn Year number.
    /// @param _driver Address of any `Driver`.
    /// @return Annual amount of Income tax payd by `Driver`
    */
    function getAnnualPaymentsOfIncomeTax(uint256 _yearn, address _driver)
        getByTrusted(_driver)
        checkYear(_yearn)
        external view returns (uint256)
    {
        return annualIncomeTax[_yearn][_driver];
    }
    
    /*
    /// @notice Gets the total amount of weekly Income Tax payments of any `Driver`.
    /// Allowed to call just from active GRS `Method` or `Driver` contract owner.
    /// @param _weekn Week number.
    /// @param _driver Address of any `Driver`.
    /// @return Weekly amount of Income tax payd by `Driver`
    */
    function getWeeklyPaymentsOfIncomeTax(uint256 _weekn, address _driver)
        getByTrusted(_driver)
        checkWeek(_weekn)
        external view returns (uint256)
    {
        return weeklyIncomeTax[_weekn][_driver];
    }
    
    /*
    /// @notice The basis of addition of General Tax payment of any entity.
    /// Addition is fixing at all levels of database needed.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed to add only for active business entity.
    /// @param _entity Address of any active entity.
    /// @param _amount Amount of Tax.
    */
    function addPaymentOfGeneralTax(address _entity, uint256 _amount)
        onlyAtActiveCB
        onlyByActiveMethod
        onlyForEntities(_entity)
        external returns (bool)
    {
        require(_amount > 0);
        uint year = _year();
        uint week = _week();
        annualGeneralTax[year][_entity] += _amount;
        weeklyGeneralTax[week][_entity] += _amount;
        return true;
    }
    
    /*
    /// @notice Gets the total amount of annual General Tax payments of any entity.
    /// Allowed to call just from active GRS `Method` or entity contract owner.
    /// @param _yearn Year number.
    /// @param _driver Address of any active entity.
    /// @return Annual amount of General tax payd by entity
    */
    function getAnnualPaymentsOfGeneralTax(uint256 _yearn, address _entity)
        getByTrusted(_entity)
        onlyForEntities(_entity)
        checkYear(_yearn)
        external view returns (uint256)
    {
        return annualGeneralTax[_yearn][_entity];
    }
    
    /*
    /// @notice Gets the total amount of weekly General Tax payments of any entity.
    /// Allowed to call just from active GRS `Method` or entity contract owner.
    /// @param _weekn Week number.
    /// @param _driver Address of any active entity.
    /// @return Weekly amount of General tax payd by entity
    */
    function getWeeklyPaymentsOfGeneralTax(uint256 _weekn, address _entity)
        getByTrusted(_entity)
        onlyForEntities(_entity)
        checkWeek(_weekn)
        external view returns (uint256)
    {
        return weeklyGeneralTax[_weekn][_entity];
    }
    
    /*
    /// @notice The basis of addition of Subsidy Tax payment of any entity.
    /// Addition is fixing at all levels of database needed.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed to add only for active business entity.
    /// @param _entity Address of any active entity.
    /// @param _amount Amount of Tax.
    */
    function addPaymentOfSubsidyTax(address _entity, uint256 _amount)
        onlyAtActiveCB
        onlyByActiveMethod
        onlyForEntities(_entity)
        external returns (bool)
    {
        require(_amount > 0);
        uint year = _year();
        uint week = _week();
        annualSubsidyTax[year][_entity] += _amount;
        weeklySubsidyTax[week][_entity] += _amount;
        return true;
    }
    
    /*
    /// @notice Gets the total amount of annual Subsidy Tax payments of any entity.
    /// Allowed to call just from active GRS `Method` or entity contract owner.
    /// @param _yearn Year number.
    /// @param _driver Address of any active entity.
    /// @return Annual amount of Subsidy tax payd by entity
    */
    function getAnnualPaymentsOfSubsidyTax(uint256 _yearn, address _entity)
        getByTrusted(_entity)
        onlyForEntities(_entity)
        checkYear(_yearn)
        external view returns (uint256)
    {
        return annualSubsidyTax[_yearn][_entity];
    }
    
    /*
    /// @notice Gets the total amount of weekly Subsidy Tax payments of any entity.
    /// Allowed to call just from active GRS `Method` or entity contract owner.
    /// @param _weekn Week number.
    /// @param _driver Address of any active entity.
    /// @return Weekly amount of Subsidy tax payd by entity
    */
    function getWeeklyPaymentsOfSubsidyTax(uint256 _weekn, address _entity)
        getByTrusted(_entity)
        onlyForEntities(_entity)
        checkWeek(_weekn)
        external view returns (uint256)
    {
        return weeklySubsidyTax[_weekn][_entity];
    }
    
    /*
    /// @notice The basis of addition of Upgrade Tax payment of any entity.
    /// Addition is fixing at all levels of database needed.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed to add only for active business entity.
    /// @param _entity Address of any active entity.
    /// @param _amount Amount of Tax.
    */
    function addPaymentOfUpgradeTax(address _entity, uint256 _amount)
        onlyAtActiveCB
        onlyByActiveMethod
        onlyForEntities(_entity)
        external returns (bool)
    {
        require(_amount > 0);
        uint year = _year();
        uint week = _week();
        annualUpgradeTax[year][_entity] += _amount;
        weeklyUpgradeTax[week][_entity] += _amount;
        return true;
    }
    
    /*
    /// @notice Gets the total amount of annual Upgrade Tax payments of any entity.
    /// Allowed to call just from active GRS `Method` or entity contract owner.
    /// @param _yearn Year number.
    /// @param _driver Address of any active entity.
    /// @return Annual amount of Upgrade tax payd by entity
    */
    function getAnnualPaymentsOfUpgradeTax(uint256 _yearn, address _entity)
        getByTrusted(_entity)
        onlyForEntities(_entity)
        checkYear(_yearn)
        external view returns (uint256)
    {
        return annualUpgradeTax[_yearn][_entity];
    }
    
    /*
    /// @notice Gets the total amount of weekly Upgrade Tax payments of any entity.
    /// Allowed to call just from active GRS `Method` or entity contract owner.
    /// @param _weekn Week number.
    /// @param _driver Address of any active entity.
    /// @return Weekly amount of Upgrade tax payd by entity
    */
    function getWeeklyPaymentsOfUpgradeTax(uint256 _weekn, address _entity)
        getByTrusted(_entity)
        onlyForEntities(_entity)
        checkWeek(_weekn)
        external view returns (uint256)
    {
        return weeklyUpgradeTax[_weekn][_entity];
    }
    
    /*
    /// @notice The basis of addition of Extra Tax payment of any entity.
    /// Addition is fixing at all levels of database needed.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed to add only for active business entity.
    /// @param _entity Address of any active entity.
    /// @param _amount Amount of Tax.
    */
    function addPaymentOfExtraTax(address _entity, uint256 _amount)
        onlyAtActiveCB
        onlyByActiveMethod
        onlyForEntities(_entity)
        external returns (bool)
    {
        require(_amount > 0);
        uint year = _year();
        uint week = _week();
        annualExtraTax[year][_entity] += _amount;
        weeklyExtraTax[week][_entity] += _amount;
        return true;
    }
    
    /*
    /// @notice Gets the total amount of annual Extra Tax payments of any entity.
    /// Allowed to call just from active GRS `Method` or entity contract owner.
    /// @param _yearn Year number.
    /// @param _driver Address of any active entity.
    /// @return Annual amount of Extra tax payd by entity
    */
    function getAnnualPaymentsOfExtraTax(uint256 _yearn, address _entity)
        getByTrusted(_entity)
        onlyForEntities(_entity)
        checkYear(_yearn)
        external view returns (uint256)
    {
        return annualExtraTax[_yearn][_entity];
    }
    
    /*
    /// @notice Gets the total amount of weekly Extra Tax payments of any entity.
    /// Allowed to call just from active GRS `Method` or entity contract owner.
    /// @param _weekn Week number.
    /// @param _driver Address of any active entity.
    /// @return Weekly amount of Extra tax payd by entity
    */
    function getWeeklyPaymentsOfExtraTax(uint256 _weekn, address _entity)
        getByTrusted(_entity)
        onlyForEntities(_entity)
        checkWeek(_weekn)
        external view returns (uint256)
    {
        return weeklyExtraTax[_weekn][_entity];
    }
    
    /*
    /// @notice The basis of addition of Migration Tax payment of any `Driver`.
    /// Addition is fixing at all levels of database needed.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed to add only for active `Driver`.
    /// @param _driver Address of any active `Driver`.
    /// @param _amount Amount of Tax.
    */
    function addPaymentOfMigrationTax(address _driver, uint256 _amount)
        onlyAtActiveCB
        onlyByActiveMethod
        onlyForActiveDriver(_driver)
        external returns (bool)
    {
        require(_amount == migrationTax);
        migrationTaxPaid[_driver] = true;
        return true;
    }
    
    /*
    /// @notice The basis of completion of Migration process of any `Driver`.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed to add only for active `Driver`.
    /// @param _driver Address of any active `Driver`.
    */
    function completeMigrationProcess(address _driver)
        onlyAtActiveCB
        onlyByActiveMethod
        onlyForActiveDriver(_driver)
        external returns (bool)
    {
        require(migrationTaxPaid[_driver]);
        migrationTaxPaid[_driver] = false;
        return true;
    }
    
    /*
    /// @notice The basis of addition of Emigration Tax payment of any `Driver`.
    /// Addition is fixing at all levels of database needed.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed to add only for active `Driver`.
    /// @param _driver Address of any active `Driver`.
    /// @param _amount Amount of Tax.
    */
    function addPaymentOfEmigrationTax(address _driver, uint256 _amount)
        onlyAtActiveCB
        onlyByActiveMethod
        onlyForActiveDriver(_driver)
        external returns (bool)
    {
        require(_amount == emigrationTax);
        emigrationTaxPaid[_driver] = true;
        return true;
    }
    
    /*
    /// @notice The basis of completion of Emigration process of any `Driver`.
    /// Allowed to call just from active GRS `Method`.
    /// Allowed to add only for active `Driver`.
    /// @param _driver Address of any active `Driver`.
    */
    function completeEmigrationProcess(address _driver)
        onlyAtActiveCB
        onlyByActiveMethod
        onlyForActiveDriver(_driver)
        external returns (bool)
    {
        require(emigrationTaxPaid[_driver]);
        emigrationTaxPaid[_driver] = false;
        return true;
    }
    
    /*
    /// @notice The basis of setting of duration of one cicle in weeks.
    /// In case of computation of loan repayment amount (methods > 0).
    /// Allowed to call just from active GRS `Method`.
    /// @param _weeks Number of weeks of one cicle.
    */
    function setCicleInWeeksForLoanRepaymentAmount(uint8 _weeks)
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        require(_weeks > 0);
        cicleInWeeksForLoanRepaymentAmount = _weeks;
        return true;
    }
    
    /*
    /// @notice The basis of setting of number of cicles.
    /// In case of computation of loan repayment amount (methods > 0).
    /// Allowed to call just from active GRS `Method`.
    /// @param _cicles Number of cicles.
    */
    function setNumberOfCiclesForLoanRepaymentAmount(uint8 _cicles)
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        require(_cicles > 3);
        numberOfCiclesForLoanRepaymentAmount = _cicles;
        return true;
    }
    
    /*
    /// @notice The basis of setting of percentage from turnover in period of cicles.
    /// In case of computation of loan repayment amount (methods > 0).
    /// Allowed to call just from active GRS `Method`.
    /// @param _perc Percentage from turnover for last amount of cicles.
    */
    function setPercentageFromTurnoverForLoanRepaymentAmount(uint8 _perc)
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        require(_perc > 5 && _perc <= grSystem.maxPercFromTurnoverForLoanRepaymentAmount());
        percentageFromTurnoverForLoanRepaymentAmount = _perc;
        return true;
    }
    
    /*
    /// @notice Add Amount of common (weekly & annual) turnovers.
    /// Allowed to call just from active GRS `Method`.
    /// Not allowed for any `CB`.
    /// @param _entity Address of account owner.
    /// @param _amount Amount of funds.
    */
    function addToTurnovers(address _entity, uint256 _amount)
        onlyAtActiveCB
        onlyByActiveMethod
        external returns (bool)
    {
        require(allActivities[_entity]);
        require(_amount > 0);
        /* Annual amount data */
        annualTurnovers[_year()][_entity] += _amount;
        /* Weekly amount data */
        weeklyTurnovers[_week()][_entity] += _amount;
        return true;
    }
    
    /*
    /// @notice Get Amount of annual turnover.
    /// Allowed to call just from trusted contract or GRS `Method`.
    /// Not allowed for any `CB`.
    /// @param _yearn Number of annual cicle.
    /// @param _entity Address of account owner.
    */
    function getAnnualTurnover(uint256 _yearn, address _entity)
        getByTrusted(_entity)
        external view returns (uint256)
    {
        require(allActivities[_entity]);
        require(_yearn > 0);
        return annualTurnovers[_yearn][_entity];
    }
    
    /*
    /// @notice Get Amount of annual turnover.
    /// Allowed to call just from trusted contract or GRS `Method`.
    /// Not allowed for any `CB`.
    /// @param _yearn Number of annual cicle.
    /// @param _entity Address of account owner.
    */
    function getWeeklyTurnover(uint256 _weekn, address _entity)
        getByTrusted(_entity)
        external view returns (uint256)
    {
        require(allActivities[_entity]);
        require(_weekn > 0);
        return annualTurnovers[_weekn][_entity];
    }
}
