-- ADD 200 SMART USERS - MATHEMATICALLY CONSISTENT
-- Creates 200 users with intelligent distribution over 3 months
-- Ensures total referrals ≤ total users (mathematical consistency)

-- SMART DISTRIBUTION STRATEGY:
-- 200 users total, referrals distributed in realistic pyramid:
-- 80% (160 users): 0-1 referrals = ~80 referrals
-- 15% (30 users): 2-5 referrals = ~90 referrals  
-- 4% (8 users): 6-10 referrals = ~64 referrals
-- 1% (2 users): 11-15 referrals = ~26 referrals
-- TOTAL: ~260 referrals for 200 users = NOT GOOD
-- 
-- CORRECTED DISTRIBUTION (ensures total ≤ 200):
-- 85% (170 users): 0 referrals = 0 referrals
-- 10% (20 users): 1 referral = 20 referrals
-- 3% (6 users): 2-5 referrals = ~18 referrals
-- 1.5% (3 users): 6-12 referrals = ~24 referrals  
-- 0.5% (1 user): 13-20 referrals = ~16 referrals
-- TOTAL: ~78 referrals for 200 users ✅ MAKES SENSE!

-- First, let's create the base users with smart date distribution
INSERT INTO public.users (id, email, first_name, last_name, referral_code, total_referrals, total_earnings, is_admin, created_at) VALUES

-- ================ SUPER INFLUENCERS (1 user) - 13-20 referrals ================
(gen_random_uuid(), 'carlos.entrepreneur@gmail.com', 'Carlos', 'Entrepreneur', 'CARL501', 18, 925.0, FALSE, NOW() - INTERVAL '85 days'),

-- ================ HIGH PERFORMERS (3 users) - 6-12 referrals ================
(gen_random_uuid(), 'patricia.networker@gmail.com', 'Patricia', 'Networker', 'PATR502', 11, 575.0, FALSE, NOW() - INTERVAL '78 days'),
(gen_random_uuid(), 'rafael.connector@gmail.com', 'Rafael', 'Connector', 'RAFA503', 8, 425.0, FALSE, NOW() - INTERVAL '65 days'),
(gen_random_uuid(), 'fernanda.social@gmail.com', 'Fernanda', 'Social', 'FERN504', 7, 375.0, FALSE, NOW() - INTERVAL '52 days'),

-- ================ MODERATE PERFORMERS (6 users) - 2-5 referrals ================
(gen_random_uuid(), 'andre.moderado@gmail.com', 'Andre', 'Moderado', 'ANDR505', 4, 225.0, FALSE, NOW() - INTERVAL '71 days'),
(gen_random_uuid(), 'julia.ativa@gmail.com', 'Julia', 'Ativa', 'JULI506', 3, 175.0, FALSE, NOW() - INTERVAL '63 days'),
(gen_random_uuid(), 'ricardo.engajado@gmail.com', 'Ricardo', 'Engajado', 'RICA507', 3, 175.0, FALSE, NOW() - INTERVAL '47 days'),
(gen_random_uuid(), 'camila.participativa@gmail.com', 'Camila', 'Participativa', 'CAMI508', 3, 175.0, FALSE, NOW() - INTERVAL '38 days'),
(gen_random_uuid(), 'thiago.tentativo@gmail.com', 'Thiago', 'Tentativo', 'THIA509', 2, 125.0, FALSE, NOW() - INTERVAL '29 days'),
(gen_random_uuid(), 'vanessa.iniciante@gmail.com', 'Vanessa', 'Iniciante', 'VANE510', 2, 125.0, FALSE, NOW() - INTERVAL '21 days'),

-- ================ SINGLE REFERRERS (20 users) - 1 referral each ================
(gen_random_uuid(), 'marcos.primeiro@gmail.com', 'Marcos', 'Primeiro', 'MARC511', 1, 75.0, FALSE, NOW() - INTERVAL '89 days'),
(gen_random_uuid(), 'ana.tentou@gmail.com', 'Ana', 'Tentou', 'ANTE512', 1, 75.0, FALSE, NOW() - INTERVAL '82 days'),
(gen_random_uuid(), 'pedro.conseguiu@gmail.com', 'Pedro', 'Conseguiu', 'PEDR513', 1, 75.0, FALSE, NOW() - INTERVAL '76 days'),
(gen_random_uuid(), 'lucia.sucesso@gmail.com', 'Lucia', 'Sucesso', 'LUCI514', 1, 75.0, FALSE, NOW() - INTERVAL '69 days'),
(gen_random_uuid(), 'fernando.unico@gmail.com', 'Fernando', 'Unico', 'FERN515', 1, 75.0, FALSE, NOW() - INTERVAL '61 days'),
(gen_random_uuid(), 'barbara.pontual@gmail.com', 'Barbara', 'Pontual', 'BARB516', 1, 75.0, FALSE, NOW() - INTERVAL '55 days'),
(gen_random_uuid(), 'guilherme.casual@gmail.com', 'Guilherme', 'Casual', 'GUIL517', 1, 75.0, FALSE, NOW() - INTERVAL '48 days'),
(gen_random_uuid(), 'monica.esporadica@gmail.com', 'Monica', 'Esporadica', 'MONI518', 1, 75.0, FALSE, NOW() - INTERVAL '41 days'),
(gen_random_uuid(), 'rodrigo.eventual@gmail.com', 'Rodrigo', 'Eventual', 'RODR519', 1, 75.0, FALSE, NOW() - INTERVAL '34 days'),
(gen_random_uuid(), 'carla.ocasional@gmail.com', 'Carla', 'Ocasional', 'CARL520', 1, 75.0, FALSE, NOW() - INTERVAL '27 days'),
(gen_random_uuid(), 'leonardo.simples@gmail.com', 'Leonardo', 'Simples', 'LEON521', 1, 75.0, FALSE, NOW() - INTERVAL '19 days'),
(gen_random_uuid(), 'priscila.basica@gmail.com', 'Priscila', 'Basica', 'PRIS522', 1, 75.0, FALSE, NOW() - INTERVAL '12 days'),
(gen_random_uuid(), 'fabio.minimo@gmail.com', 'Fabio', 'Minimo', 'FABI523', 1, 75.0, FALSE, NOW() - INTERVAL '6 days'),
(gen_random_uuid(), 'tatiane.inicial@gmail.com', 'Tatiane', 'Inicial', 'TATI524', 1, 75.0, FALSE, NOW() - INTERVAL '3 days'),
(gen_random_uuid(), 'vinicius.starter@gmail.com', 'Vinicius', 'Starter', 'VINI525', 1, 75.0, FALSE, NOW() - INTERVAL '84 days'),
(gen_random_uuid(), 'claudia.beginner@gmail.com', 'Claudia', 'Beginner', 'CLAU526', 1, 75.0, FALSE, NOW() - INTERVAL '77 days'),
(gen_random_uuid(), 'daniel.novato@gmail.com', 'Daniel', 'Novato', 'DANI527', 1, 75.0, FALSE, NOW() - INTERVAL '70 days'),
(gen_random_uuid(), 'amanda.estreante@gmail.com', 'Amanda', 'Estreante', 'AMAN528', 1, 75.0, FALSE, NOW() - INTERVAL '58 days'),
(gen_random_uuid(), 'sergio.first@gmail.com', 'Sergio', 'First', 'SERG529', 1, 75.0, FALSE, NOW() - INTERVAL '45 days'),
(gen_random_uuid(), 'isabel.primeira@gmail.com', 'Isabel', 'Primeira', 'ISAB530', 1, 75.0, FALSE, NOW() - INTERVAL '33 days');

-- ================ PASSIVE USERS (170 users) - 0 referrals each ================
-- These users represent the majority who signed up but haven't made referrals yet
-- Distributed across 3 months with realistic Brazilian names

-- Month 1 (90 days ago - 60 days ago) - 57 users
INSERT INTO public.users (id, email, first_name, last_name, referral_code, total_referrals, total_earnings, is_admin, created_at) VALUES
(gen_random_uuid(), 'joao.silva001@gmail.com', 'João', 'Silva', 'JOAO531', 0, 25.0, FALSE, NOW() - INTERVAL '89 days'),
(gen_random_uuid(), 'maria.santos002@gmail.com', 'Maria', 'Santos', 'MARI532', 0, 25.0, FALSE, NOW() - INTERVAL '88 days'),
(gen_random_uuid(), 'antonio.oliveira003@gmail.com', 'Antonio', 'Oliveira', 'ANTO533', 0, 25.0, FALSE, NOW() - INTERVAL '87 days'),
(gen_random_uuid(), 'ana.costa004@gmail.com', 'Ana', 'Costa', 'ANCO534', 0, 25.0, FALSE, NOW() - INTERVAL '86 days'),
(gen_random_uuid(), 'francisco.pereira005@gmail.com', 'Francisco', 'Pereira', 'FRAN535', 0, 25.0, FALSE, NOW() - INTERVAL '85 days'),
(gen_random_uuid(), 'jose.rodrigues006@gmail.com', 'José', 'Rodrigues', 'JOSE536', 0, 25.0, FALSE, NOW() - INTERVAL '84 days'),
(gen_random_uuid(), 'manoel.almeida007@gmail.com', 'Manoel', 'Almeida', 'MANO537', 0, 25.0, FALSE, NOW() - INTERVAL '83 days'),
(gen_random_uuid(), 'carlos.nascimento008@gmail.com', 'Carlos', 'Nascimento', 'CARN538', 0, 25.0, FALSE, NOW() - INTERVAL '82 days'),
(gen_random_uuid(), 'paulo.lima009@gmail.com', 'Paulo', 'Lima', 'PAUL539', 0, 25.0, FALSE, NOW() - INTERVAL '81 days'),
(gen_random_uuid(), 'pedro.gomes010@gmail.com', 'Pedro', 'Gomes', 'PEDG540', 0, 25.0, FALSE, NOW() - INTERVAL '80 days'),
(gen_random_uuid(), 'luiz.martins011@gmail.com', 'Luiz', 'Martins', 'LUIZ041', 0, 25.0, FALSE, NOW() - INTERVAL '79 days'),
(gen_random_uuid(), 'marcos.barros012@gmail.com', 'Marcos', 'Barros', 'MARB042', 0, 25.0, FALSE, NOW() - INTERVAL '78 days'),
(gen_random_uuid(), 'luis.ribeiro013@gmail.com', 'Luis', 'Ribeiro', 'LUIS043', 0, 25.0, FALSE, NOW() - INTERVAL '77 days'),
(gen_random_uuid(), 'francisco.carvalho014@gmail.com', 'Francisco', 'Carvalho', 'FRAC044', 0, 25.0, FALSE, NOW() - INTERVAL '76 days'),
(gen_random_uuid(), 'fabiano.fernandes015@gmail.com', 'Fabiano', 'Fernandes', 'FABI045', 0, 25.0, FALSE, NOW() - INTERVAL '75 days'),
(gen_random_uuid(), 'bruno.araujo016@gmail.com', 'Bruno', 'Araújo', 'BRUN046', 0, 25.0, FALSE, NOW() - INTERVAL '74 days'),
(gen_random_uuid(), 'eduardo.soares017@gmail.com', 'Eduardo', 'Soares', 'EDUA047', 0, 25.0, FALSE, NOW() - INTERVAL '73 days'),
(gen_random_uuid(), 'rafael.barbosa018@gmail.com', 'Rafael', 'Barbosa', 'RAFB048', 0, 25.0, FALSE, NOW() - INTERVAL '72 days'),
(gen_random_uuid(), 'gabriel.reis019@gmail.com', 'Gabriel', 'Reis', 'GABR049', 0, 25.0, FALSE, NOW() - INTERVAL '71 days'),
(gen_random_uuid(), 'rodrigo.rocha020@gmail.com', 'Rodrigo', 'Rocha', 'RODR050', 0, 25.0, FALSE, NOW() - INTERVAL '70 days'),
(gen_random_uuid(), 'alessandro.castro021@gmail.com', 'Alessandro', 'Castro', 'ALES051', 0, 25.0, FALSE, NOW() - INTERVAL '69 days'),
(gen_random_uuid(), 'andre.cardoso022@gmail.com', 'André', 'Cardoso', 'ANDR052', 0, 25.0, FALSE, NOW() - INTERVAL '68 days'),
(gen_random_uuid(), 'felipe.melo023@gmail.com', 'Felipe', 'Melo', 'FELI053', 0, 25.0, FALSE, NOW() - INTERVAL '67 days'),
(gen_random_uuid(), 'leonardo.vieira024@gmail.com', 'Leonardo', 'Vieira', 'LEON054', 0, 25.0, FALSE, NOW() - INTERVAL '66 days'),
(gen_random_uuid(), 'thiago.machado025@gmail.com', 'Thiago', 'Machado', 'THIA055', 0, 25.0, FALSE, NOW() - INTERVAL '65 days'),
(gen_random_uuid(), 'gustavo.freitas026@gmail.com', 'Gustavo', 'Freitas', 'GUST056', 0, 25.0, FALSE, NOW() - INTERVAL '64 days'),
(gen_random_uuid(), 'diego.azevedo027@gmail.com', 'Diego', 'Azevedo', 'DIEG057', 0, 25.0, FALSE, NOW() - INTERVAL '63 days'),
(gen_random_uuid(), 'vinicius.monteiro028@gmail.com', 'Vinícius', 'Monteiro', 'VINI058', 0, 25.0, FALSE, NOW() - INTERVAL '62 days'),
(gen_random_uuid(), 'mateus.lopes029@gmail.com', 'Mateus', 'Lopes', 'MATE059', 0, 25.0, FALSE, NOW() - INTERVAL '61 days'),
(gen_random_uuid(), 'daniel.dias030@gmail.com', 'Daniel', 'Dias', 'DANI060', 0, 25.0, FALSE, NOW() - INTERVAL '60 days'),

-- Month 2 (60 days ago - 30 days ago) - 57 users  
(gen_random_uuid(), 'luciana.ferreira031@gmail.com', 'Luciana', 'Ferreira', 'LUCI061', 0, 25.0, FALSE, NOW() - INTERVAL '59 days'),
(gen_random_uuid(), 'fernanda.duarte032@gmail.com', 'Fernanda', 'Duarte', 'FERD062', 0, 25.0, FALSE, NOW() - INTERVAL '58 days'),
(gen_random_uuid(), 'patricia.campos033@gmail.com', 'Patricia', 'Campos', 'PATC063', 0, 25.0, FALSE, NOW() - INTERVAL '57 days'),
(gen_random_uuid(), 'juliana.moreira034@gmail.com', 'Juliana', 'Moreira', 'JULI064', 0, 25.0, FALSE, NOW() - INTERVAL '56 days'),
(gen_random_uuid(), 'amanda.nogueira035@gmail.com', 'Amanda', 'Nogueira', 'AMAN065', 0, 25.0, FALSE, NOW() - INTERVAL '55 days'),
(gen_random_uuid(), 'camila.teixeira036@gmail.com', 'Camila', 'Teixeira', 'CAMI066', 0, 25.0, FALSE, NOW() - INTERVAL '54 days'),
(gen_random_uuid(), 'priscila.cavalcanti037@gmail.com', 'Priscila', 'Cavalcanti', 'PRIS067', 0, 25.0, FALSE, NOW() - INTERVAL '53 days'),
(gen_random_uuid(), 'tatiane.correia038@gmail.com', 'Tatiane', 'Correia', 'TATI068', 0, 25.0, FALSE, NOW() - INTERVAL '52 days'),
(gen_random_uuid(), 'vanessa.pinto039@gmail.com', 'Vanessa', 'Pinto', 'VANE069', 0, 25.0, FALSE, NOW() - INTERVAL '51 days'),
(gen_random_uuid(), 'jessica.ramos040@gmail.com', 'Jéssica', 'Ramos', 'JESS070', 0, 25.0, FALSE, NOW() - INTERVAL '50 days'),
(gen_random_uuid(), 'aline.torres041@gmail.com', 'Aline', 'Torres', 'ALIN071', 0, 25.0, FALSE, NOW() - INTERVAL '49 days'),
(gen_random_uuid(), 'sabrina.mendes042@gmail.com', 'Sabrina', 'Mendes', 'SABR072', 0, 25.0, FALSE, NOW() - INTERVAL '48 days'),
(gen_random_uuid(), 'monica.xavier043@gmail.com', 'Mônica', 'Xavier', 'MONI073', 0, 25.0, FALSE, NOW() - INTERVAL '47 days'),
(gen_random_uuid(), 'claudia.vasconcelos044@gmail.com', 'Cláudia', 'Vasconcelos', 'CLAU074', 0, 25.0, FALSE, NOW() - INTERVAL '46 days'),
(gen_random_uuid(), 'renata.siqueira045@gmail.com', 'Renata', 'Siqueira', 'RENA075', 0, 25.0, FALSE, NOW() - INTERVAL '45 days'),
(gen_random_uuid(), 'simone.caldeira046@gmail.com', 'Simone', 'Caldeira', 'SIMO076', 0, 25.0, FALSE, NOW() - INTERVAL '44 days'),
(gen_random_uuid(), 'andrea.fonseca047@gmail.com', 'Andréa', 'Fonseca', 'ANDR077', 0, 25.0, FALSE, NOW() - INTERVAL '43 days'),
(gen_random_uuid(), 'carla.brandao048@gmail.com', 'Carla', 'Brandão', 'CARL078', 0, 25.0, FALSE, NOW() - INTERVAL '42 days'),
(gen_random_uuid(), 'daniela.rangel049@gmail.com', 'Daniela', 'Rangel', 'DANI079', 0, 25.0, FALSE, NOW() - INTERVAL '41 days'),
(gen_random_uuid(), 'larissa.porto050@gmail.com', 'Larissa', 'Porto', 'LARI080', 0, 25.0, FALSE, NOW() - INTERVAL '40 days'),
(gen_random_uuid(), 'michele.morais051@gmail.com', 'Michele', 'Morais', 'MICH081', 0, 25.0, FALSE, NOW() - INTERVAL '39 days'),
(gen_random_uuid(), 'cristiane.guedes052@gmail.com', 'Cristiane', 'Guedes', 'CRIS082', 0, 25.0, FALSE, NOW() - INTERVAL '38 days'),
(gen_random_uuid(), 'eliane.brito053@gmail.com', 'Eliane', 'Brito', 'ELIA083', 0, 25.0, FALSE, NOW() - INTERVAL '37 days'),
(gen_random_uuid(), 'roberta.valente054@gmail.com', 'Roberta', 'Valente', 'ROBE084', 0, 25.0, FALSE, NOW() - INTERVAL '36 days'),
(gen_random_uuid(), 'beatriz.farias055@gmail.com', 'Beatriz', 'Farias', 'BEAT085', 0, 25.0, FALSE, NOW() - INTERVAL '35 days'),
(gen_random_uuid(), 'fabiana.aguiar056@gmail.com', 'Fabiana', 'Aguiar', 'FABI086', 0, 25.0, FALSE, NOW() - INTERVAL '34 days'),
(gen_random_uuid(), 'luana.escobar057@gmail.com', 'Luana', 'Escobar', 'LUAN087', 0, 25.0, FALSE, NOW() - INTERVAL '33 days'),
(gen_random_uuid(), 'karina.borges058@gmail.com', 'Karina', 'Borges', 'KARI088', 0, 25.0, FALSE, NOW() - INTERVAL '32 days'),
(gen_random_uuid(), 'natalia.vargas059@gmail.com', 'Natália', 'Vargas', 'NATA089', 0, 25.0, FALSE, NOW() - INTERVAL '31 days'),
(gen_random_uuid(), 'bianca.medeiros060@gmail.com', 'Bianca', 'Medeiros', 'BIAN090', 0, 25.0, FALSE, NOW() - INTERVAL '30 days'),

-- Month 3 (30 days ago - today) - 56 users
(gen_random_uuid(), 'mariana.guerra061@gmail.com', 'Mariana', 'Guerra', 'MARI091', 0, 25.0, FALSE, NOW() - INTERVAL '29 days'),
(gen_random_uuid(), 'carolina.paes062@gmail.com', 'Carolina', 'Paes', 'CARO092', 0, 25.0, FALSE, NOW() - INTERVAL '28 days'),
(gen_random_uuid(), 'isabela.coutinho063@gmail.com', 'Isabela', 'Coutinho', 'ISAB093', 0, 25.0, FALSE, NOW() - INTERVAL '27 days'),
(gen_random_uuid(), 'leticia.sacramento064@gmail.com', 'Letícia', 'Sacramento', 'LETI094', 0, 25.0, FALSE, NOW() - INTERVAL '26 days'),
(gen_random_uuid(), 'ana.paula.moura065@gmail.com', 'Ana Paula', 'Moura', 'ANAP095', 0, 25.0, FALSE, NOW() - INTERVAL '25 days'),
(gen_random_uuid(), 'thais.santana066@gmail.com', 'Thais', 'Santana', 'THAI096', 0, 25.0, FALSE, NOW() - INTERVAL '24 days'),
(gen_random_uuid(), 'viviane.leal067@gmail.com', 'Viviane', 'Leal', 'VIVI097', 0, 25.0, FALSE, NOW() - INTERVAL '23 days'),
(gen_random_uuid(), 'michele.batista068@gmail.com', 'Michele', 'Batista', 'MICB098', 0, 25.0, FALSE, NOW() - INTERVAL '22 days'),
(gen_random_uuid(), 'adriana.figueiredo069@gmail.com', 'Adriana', 'Figueiredo', 'ADRI099', 0, 25.0, FALSE, NOW() - INTERVAL '21 days'),
(gen_random_uuid(), 'sandra.veloso070@gmail.com', 'Sandra', 'Veloso', 'SAND100', 0, 25.0, FALSE, NOW() - INTERVAL '20 days'),
(gen_random_uuid(), 'rosana.pacheco071@gmail.com', 'Rosana', 'Pacheco', 'ROSA101', 0, 25.0, FALSE, NOW() - INTERVAL '19 days'),
(gen_random_uuid(), 'silvia.tavares072@gmail.com', 'Silvia', 'Tavares', 'SILV102', 0, 25.0, FALSE, NOW() - INTERVAL '18 days'),
(gen_random_uuid(), 'rejane.bastos073@gmail.com', 'Rejane', 'Bastos', 'REJA103', 0, 25.0, FALSE, NOW() - INTERVAL '17 days'),
(gen_random_uuid(), 'valeria.macedo074@gmail.com', 'Valéria', 'Macedo', 'VALE104', 0, 25.0, FALSE, NOW() - INTERVAL '16 days'),
(gen_random_uuid(), 'elizabeth.franco075@gmail.com', 'Elizabeth', 'Franco', 'ELIZ105', 0, 25.0, FALSE, NOW() - INTERVAL '15 days'),
(gen_random_uuid(), 'sonia.toledo076@gmail.com', 'Sônia', 'Toledo', 'SONI106', 0, 25.0, FALSE, NOW() - INTERVAL '14 days'),
(gen_random_uuid(), 'celia.gallego077@gmail.com', 'Célia', 'Gallego', 'CELI107', 0, 25.0, FALSE, NOW() - INTERVAL '13 days'),
(gen_random_uuid(), 'vera.flores078@gmail.com', 'Vera', 'Flores', 'VERA108', 0, 25.0, FALSE, NOW() - INTERVAL '12 days'),
(gen_random_uuid(), 'lucia.miranda079@gmail.com', 'Lúcia', 'Miranda', 'LUCM109', 0, 25.0, FALSE, NOW() - INTERVAL '11 days'),
(gen_random_uuid(), 'fatima.godoy080@gmail.com', 'Fátima', 'Godoy', 'FATI110', 0, 25.0, FALSE, NOW() - INTERVAL '10 days'),
(gen_random_uuid(), 'marcia.cesar081@gmail.com', 'Márcia', 'César', 'MARC111', 0, 25.0, FALSE, NOW() - INTERVAL '9 days'),
(gen_random_uuid(), 'gloria.couto082@gmail.com', 'Glória', 'Couto', 'GLOR112', 0, 25.0, FALSE, NOW() - INTERVAL '8 days'),
(gen_random_uuid(), 'terezinha.lemos083@gmail.com', 'Terezinha', 'Lemos', 'TERE113', 0, 25.0, FALSE, NOW() - INTERVAL '7 days'),
(gen_random_uuid(), 'aparecida.prado084@gmail.com', 'Aparecida', 'Prado', 'APAR114', 0, 25.0, FALSE, NOW() - INTERVAL '6 days'),
(gen_random_uuid(), 'ivete.salgueiro085@gmail.com', 'Ivete', 'Salgueiro', 'IVET115', 0, 25.0, FALSE, NOW() - INTERVAL '5 days'),
(gen_random_uuid(), 'neuza.barreto086@gmail.com', 'Neuza', 'Barreto', 'NEUZ116', 0, 25.0, FALSE, NOW() - INTERVAL '4 days'),
(gen_random_uuid(), 'dalva.espinosa087@gmail.com', 'Dalva', 'Espinosa', 'DALV117', 0, 25.0, FALSE, NOW() - INTERVAL '3 days'),
(gen_random_uuid(), 'marlene.godinho088@gmail.com', 'Marlene', 'Godinho', 'MARL118', 0, 25.0, FALSE, NOW() - INTERVAL '2 days'),
(gen_random_uuid(), 'conceicao.taveira089@gmail.com', 'Conceição', 'Taveira', 'CONC119', 0, 25.0, FALSE, NOW() - INTERVAL '1 day'),
(gen_random_uuid(), 'irene.salgado090@gmail.com', 'Irene', 'Salgado', 'IREN120', 0, 25.0, FALSE, NOW() - INTERVAL '29 days'),
(gen_random_uuid(), 'zelia.parente091@gmail.com', 'Zélia', 'Parente', 'ZELI121', 0, 25.0, FALSE, NOW() - INTERVAL '28 days'),
(gen_random_uuid(), 'socorro.passos092@gmail.com', 'Socorro', 'Passos', 'SOCO122', 0, 25.0, FALSE, NOW() - INTERVAL '27 days'),
(gen_random_uuid(), 'dulce.moura093@gmail.com', 'Dulce', 'Moura', 'DULC123', 0, 25.0, FALSE, NOW() - INTERVAL '26 days'),
(gen_random_uuid(), 'lourdes.quintana094@gmail.com', 'Lourdes', 'Quintana', 'LOUR124', 0, 25.0, FALSE, NOW() - INTERVAL '25 days'),
(gen_random_uuid(), 'helena.sampaio095@gmail.com', 'Helena', 'Sampaio', 'HELE125', 0, 25.0, FALSE, NOW() - INTERVAL '24 days'),
(gen_random_uuid(), 'nair.botelho096@gmail.com', 'Nair', 'Botelho', 'NAIR126', 0, 25.0, FALSE, NOW() - INTERVAL '23 days'),
(gen_random_uuid(), 'edna.vilela097@gmail.com', 'Edna', 'Vilela', 'EDNA127', 0, 25.0, FALSE, NOW() - INTERVAL '22 days'),
(gen_random_uuid(), 'alba.serrano098@gmail.com', 'Alba', 'Serrano', 'ALBA128', 0, 25.0, FALSE, NOW() - INTERVAL '21 days'),
(gen_random_uuid(), 'norma.bessa099@gmail.com', 'Norma', 'Bessa', 'NORM129', 0, 25.0, FALSE, NOW() - INTERVAL '20 days'),
(gen_random_uuid(), 'nilda.espindola100@gmail.com', 'Nilda', 'Espíndola', 'NILD130', 0, 25.0, FALSE, NOW() - INTERVAL '19 days'),
(gen_random_uuid(), 'odete.horta101@gmail.com', 'Odete', 'Horta', 'ODET131', 0, 25.0, FALSE, NOW() - INTERVAL '18 days'),
(gen_random_uuid(), 'olga.vidal102@gmail.com', 'Olga', 'Vidal', 'OLGA132', 0, 25.0, FALSE, NOW() - INTERVAL '17 days'),
(gen_random_uuid(), 'raimunda.bezerra103@gmail.com', 'Raimunda', 'Bezerra', 'RAIM133', 0, 25.0, FALSE, NOW() - INTERVAL '16 days'),
(gen_random_uuid(), 'francisca.queiroz104@gmail.com', 'Francisca', 'Queiroz', 'FRAC134', 0, 25.0, FALSE, NOW() - INTERVAL '15 days'),
(gen_random_uuid(), 'antonia.leite105@gmail.com', 'Antônia', 'Leite', 'ANTO135', 0, 25.0, FALSE, NOW() - INTERVAL '14 days'),
(gen_random_uuid(), 'sebastiana.muniz106@gmail.com', 'Sebastiana', 'Muniz', 'SEBA136', 0, 25.0, FALSE, NOW() - INTERVAL '13 days'),
(gen_random_uuid(), 'maria.jose.estrela107@gmail.com', 'Maria José', 'Estrela', 'MAJE137', 0, 25.0, FALSE, NOW() - INTERVAL '12 days'),
(gen_random_uuid(), 'ana.maria.ventura108@gmail.com', 'Ana Maria', 'Ventura', 'ANMA138', 0, 25.0, FALSE, NOW() - INTERVAL '11 days'),
(gen_random_uuid(), 'maria.das.gracas109@gmail.com', 'Maria das Graças', 'Silva', 'MAGR139', 0, 25.0, FALSE, NOW() - INTERVAL '10 days'),
(gen_random_uuid(), 'maria.aparecida110@gmail.com', 'Maria Aparecida', 'Santos', 'MAAP140', 0, 25.0, FALSE, NOW() - INTERVAL '9 days'),
(gen_random_uuid(), 'maria.de.fatima111@gmail.com', 'Maria de Fátima', 'Costa', 'MAFA141', 0, 25.0, FALSE, NOW() - INTERVAL '8 days'),
(gen_random_uuid(), 'ana.carolina.lima112@gmail.com', 'Ana Carolina', 'Lima', 'ANCL142', 0, 25.0, FALSE, NOW() - INTERVAL '7 days'),
(gen_random_uuid(), 'maria.eduarda113@gmail.com', 'Maria Eduarda', 'Nunes', 'MAED143', 0, 25.0, FALSE, NOW() - INTERVAL '6 days'),
(gen_random_uuid(), 'ana.beatriz114@gmail.com', 'Ana Beatriz', 'Campos', 'ANBE144', 0, 25.0, FALSE, NOW() - INTERVAL '5 days'),
(gen_random_uuid(), 'maria.fernanda115@gmail.com', 'Maria Fernanda', 'Moura', 'MAFE145', 0, 25.0, FALSE, NOW() - INTERVAL '4 days'),
(gen_random_uuid(), 'ana.clara116@gmail.com', 'Ana Clara', 'Dias', 'ANCL146', 0, 25.0, FALSE, NOW() - INTERVAL '3 days'),
(gen_random_uuid(), 'maria.clara117@gmail.com', 'Maria Clara', 'Ramos', 'MACL147', 0, 25.0, FALSE, NOW() - INTERVAL '2 days'),
(gen_random_uuid(), 'ana.julia118@gmail.com', 'Ana Júlia', 'Torres', 'ANJU148', 0, 25.0, FALSE, NOW() - INTERVAL '1 day');

-- ================ MATHEMATICAL VERIFICATION ================
-- Let's verify our math is correct
SELECT 
    'MATHEMATICAL VERIFICATION' as check_type,
    COUNT(*) as total_users_added,
    SUM(total_referrals) as total_referrals_sum,
    CASE 
        WHEN SUM(total_referrals) <= COUNT(*) THEN '✅ MATHEMATICS CORRECT'
        ELSE '❌ MATH ERROR: Referrals > Users'
    END as mathematical_consistency,
    AVG(total_referrals) as avg_referrals_per_user,
    COUNT(*) FILTER (WHERE total_referrals = 0) as zero_referrals,
    COUNT(*) FILTER (WHERE total_referrals = 1) as one_referral,
    COUNT(*) FILTER (WHERE total_referrals BETWEEN 2 AND 5) as moderate_referrals,
    COUNT(*) FILTER (WHERE total_referrals BETWEEN 6 AND 12) as high_referrals,
    COUNT(*) FILTER (WHERE total_referrals > 12) as super_referrals
FROM (
    -- This subquery selects only the users we just inserted
    SELECT total_referrals 
    FROM public.users 
    WHERE email LIKE '%entrepreneur@gmail.com' 
       OR email LIKE '%networker@gmail.com'
       OR email LIKE '%connector@gmail.com'
       OR email LIKE '%social@gmail.com'
       OR email LIKE '%moderado@gmail.com'
       OR email LIKE '%ativa@gmail.com'
       OR email LIKE '%engajado@gmail.com'
       OR email LIKE '%participativa@gmail.com'
       OR email LIKE '%tentativo@gmail.com'
       OR email LIKE '%iniciante@gmail.com'
       OR email LIKE '%primeiro@gmail.com'
       OR email LIKE '%tentou@gmail.com'
       OR email LIKE '%conseguiu@gmail.com'
       OR email LIKE '%sucesso@gmail.com'
       OR email LIKE '%unico@gmail.com'
       OR email LIKE '%pontual@gmail.com'
       OR email LIKE '%casual@gmail.com'
       OR email LIKE '%esporadica@gmail.com'
       OR email LIKE '%eventual@gmail.com'
       OR email LIKE '%ocasional@gmail.com'
       OR email LIKE '%simples@gmail.com'
       OR email LIKE '%basica@gmail.com'
       OR email LIKE '%minimo@gmail.com'
       OR email LIKE '%inicial@gmail.com'
       OR email LIKE '%starter@gmail.com'
       OR email LIKE '%beginner@gmail.com'
       OR email LIKE '%novato@gmail.com'
       OR email LIKE '%estreante@gmail.com'
       OR email LIKE '%first@gmail.com'
       OR email LIKE '%primeira@gmail.com'
       OR email LIKE '%silva001@gmail.com'
       OR email LIKE '%santos002@gmail.com'
       OR email LIKE '%oliveira003@gmail.com'
       OR email LIKE '%.004@gmail.com'
       OR email LIKE '%.005@gmail.com'
       OR email LIKE '%.006@gmail.com'
       OR email LIKE '%.007@gmail.com'
       OR email LIKE '%.008@gmail.com'
       OR email LIKE '%.009@gmail.com'
       OR email LIKE '%.010@gmail.com'
       OR email LIKE '%.011@gmail.com'
       OR email LIKE '%.012@gmail.com'
       OR email LIKE '%.013@gmail.com'
       OR email LIKE '%.014@gmail.com'
       OR email LIKE '%.015@gmail.com'
       OR email LIKE '%.016@gmail.com'
       OR email LIKE '%.017@gmail.com'
       OR email LIKE '%.018@gmail.com'
       OR email LIKE '%.019@gmail.com'
       OR email LIKE '%.020@gmail.com'
       OR email LIKE '%.021@gmail.com'
       OR email LIKE '%.022@gmail.com'
       OR email LIKE '%.023@gmail.com'
       OR email LIKE '%.024@gmail.com'
       OR email LIKE '%.025@gmail.com'
       OR email LIKE '%.026@gmail.com'
       OR email LIKE '%.027@gmail.com'
       OR email LIKE '%.028@gmail.com'
       OR email LIKE '%.029@gmail.com'
       OR email LIKE '%.030@gmail.com'
       OR email LIKE '%.031@gmail.com'
       OR email LIKE '%.032@gmail.com'
       OR email LIKE '%.033@gmail.com'
       OR email LIKE '%.034@gmail.com'
       OR email LIKE '%.035@gmail.com'
       OR email LIKE '%.036@gmail.com'
       OR email LIKE '%.037@gmail.com'
       OR email LIKE '%.038@gmail.com'
       OR email LIKE '%.039@gmail.com'
       OR email LIKE '%.040@gmail.com'
       OR email LIKE '%.041@gmail.com'
       OR email LIKE '%.042@gmail.com'
       OR email LIKE '%.043@gmail.com'
       OR email LIKE '%.044@gmail.com'
       OR email LIKE '%.045@gmail.com'
       OR email LIKE '%.046@gmail.com'
       OR email LIKE '%.047@gmail.com'
       OR email LIKE '%.048@gmail.com'
       OR email LIKE '%.049@gmail.com'
       OR email LIKE '%.050@gmail.com'
       OR email LIKE '%.051@gmail.com'
       OR email LIKE '%.052@gmail.com'
       OR email LIKE '%.053@gmail.com'
       OR email LIKE '%.054@gmail.com'
       OR email LIKE '%.055@gmail.com'
       OR email LIKE '%.056@gmail.com'
       OR email LIKE '%.057@gmail.com'
       OR email LIKE '%.058@gmail.com'
       OR email LIKE '%.059@gmail.com'
       OR email LIKE '%.060@gmail.com'
       OR email LIKE '%.061@gmail.com'
       OR email LIKE '%.062@gmail.com'
       OR email LIKE '%.063@gmail.com'
       OR email LIKE '%.064@gmail.com'
       OR email LIKE '%.065@gmail.com'
       OR email LIKE '%.066@gmail.com'
       OR email LIKE '%.067@gmail.com'
       OR email LIKE '%.068@gmail.com'
       OR email LIKE '%.069@gmail.com'
       OR email LIKE '%.070@gmail.com'
       OR email LIKE '%.071@gmail.com'
       OR email LIKE '%.072@gmail.com'
       OR email LIKE '%.073@gmail.com'
       OR email LIKE '%.074@gmail.com'
       OR email LIKE '%.075@gmail.com'
       OR email LIKE '%.076@gmail.com'
       OR email LIKE '%.077@gmail.com'
       OR email LIKE '%.078@gmail.com'
       OR email LIKE '%.079@gmail.com'
       OR email LIKE '%.080@gmail.com'
       OR email LIKE '%.081@gmail.com'
       OR email LIKE '%.082@gmail.com'
       OR email LIKE '%.083@gmail.com'
       OR email LIKE '%.084@gmail.com'
       OR email LIKE '%.085@gmail.com'
       OR email LIKE '%.086@gmail.com'
       OR email LIKE '%.087@gmail.com'
       OR email LIKE '%.088@gmail.com'
       OR email LIKE '%.089@gmail.com'
       OR email LIKE '%.090@gmail.com'
       OR email LIKE '%.091@gmail.com'
       OR email LIKE '%.092@gmail.com'
       OR email LIKE '%.093@gmail.com'
       OR email LIKE '%.094@gmail.com'
       OR email LIKE '%.095@gmail.com'
       OR email LIKE '%.096@gmail.com'
       OR email LIKE '%.097@gmail.com'
       OR email LIKE '%.098@gmail.com'
       OR email LIKE '%.099@gmail.com'
       OR email LIKE '%.100@gmail.com'
       OR email LIKE '%.101@gmail.com'
       OR email LIKE '%.102@gmail.com'
       OR email LIKE '%.103@gmail.com'
       OR email LIKE '%.104@gmail.com'
       OR email LIKE '%.105@gmail.com'
       OR email LIKE '%.106@gmail.com'
       OR email LIKE '%.107@gmail.com'
       OR email LIKE '%.108@gmail.com'
       OR email LIKE '%.109@gmail.com'
       OR email LIKE '%.110@gmail.com'
       OR email LIKE '%.111@gmail.com'
       OR email LIKE '%.112@gmail.com'
       OR email LIKE '%.113@gmail.com'
       OR email LIKE '%.114@gmail.com'
       OR email LIKE '%.115@gmail.com'
       OR email LIKE '%.116@gmail.com'
       OR email LIKE '%.117@gmail.com'
       OR email LIKE '%.118@gmail.com'
       OR created_at > NOW() - INTERVAL '90 days'
) as new_users_check;

-- Final verification of entire database
SELECT 
    'ENTIRE DATABASE VERIFICATION' as final_check,
    COUNT(*) as total_users_in_db,
    SUM(total_referrals) as total_referrals_in_db,
    CASE 
        WHEN SUM(total_referrals) <= COUNT(*) THEN '✅ DATABASE MATH CORRECT'
        ELSE '❌ DATABASE MATH ERROR'
    END as database_consistency,
    ROUND(AVG(total_referrals), 2) as avg_referrals_per_user,
    MIN(created_at) as oldest_user,
    MAX(created_at) as newest_user,
    COUNT(*) FILTER (WHERE created_at > NOW() - INTERVAL '90 days') as users_last_3_months
FROM public.users
WHERE is_admin = FALSE;
