# Além do Leito

> Jogo educativo point-and-click sobre investigação de surto hospitalar e valorização dos trabalhadores invisíveis da saúde.

---

## Sobre o projeto

**Além do Leito** é um jogo educativo no formato *point-and-click*, desenvolvido como projeto final da disciplina de Educação e Saúde da Universidade Federal de Ciências da Saúde de Porto Alegre (UFCSPA).

O jogador assume o papel de um agente de vigilância epidemiológica em treinamento e investiga um surto de *Legionella pneumophila* no Hospital São Lucas, coletando pistas em três cenas: a UTI, o dormitório de plantão e o laboratório de microbiologia.

A narrativa é construída a partir de uma situação-problema fictícia, mas tecnicamente verossímil, baseada em casos reais de surtos hospitalares associados a falhas na manutenção de sistemas de climatização. O objetivo central não é apenas identificar o agente etiológico, mas evidenciar a interdependência entre os diferentes profissionais do hospital — especialmente aqueles cujo trabalho costuma ser invisibilizado.

---

## Base científica

- Portaria GM/MS nº 3.523/1998 — PMOC obrigatório em sistemas de climatização de ambientes coletivos
- Lei nº 13.589/2018 — manutenção de instalações de climatização
- Afonso et al. (2004) — qualidade do ar em ambientes hospitalares climatizados
- Chezganova et al. (2021) — ventilação como reservatório de microrganismos multirresistentes
- Huang et al. (2023) — investigação de surto em hospital designado para COVID-19
- Yanke et al. (2021) — "The Invisible Staff"
- Carvalho et al. (2023) — trabalhadores de apoio hospitalar no enfrentamento da COVID-19

---

## Mecânica

- Cenas investigativas com objetos e personagens clicáveis
- Sistema de pistas com inventário (tecla **Tab**) e HUD de progresso por cena (`x/3`)
- Diálogos ramificados com os personagens via Dialogue Manager 3
- Retratos dos personagens exibidos durante as falas
- Relatório epidemiológico final compilando todas as pistas coletadas
- Tela de créditos com texto de encerramento sobre os trabalhadores invisíveis

---

## Personagens

| Personagem | Papel |
|---|---|
| Dra. Renata Souza | Infectologista — tutora do jogador |
| Téc. Iolanda | Técnica de higienização — 18 anos no hospital |
| Enf. Marcos | Enfermeiro supervisor da UTI |
| Téc. Fernanda | Técnica de enfermagem — adoecida no surto |
| Camila | Biomédica do laboratório de microbiologia |

---

## Cenas

```
Prólogo (fachada do hospital)
    ↓
UTI — 3 pistas: grade de ventilação, prontuário, registro de manutenção
    ↓
Dormitório de plantão — 3 pistas: grade na parede, escala de plantão, Fernanda
    ↓
Laboratório de microbiologia — 3 pistas: placa de cultura, computador, quadro branco
    ↓
Epílogo (corredor) + Relatório epidemiológico + Créditos
```

---

## Tecnologias

- [Godot Engine 4.6](https://godotengine.org/) — engine principal
- [Dialogue Manager 3](https://github.com/nathanhoad/godot_dialogue_manager) — sistema de diálogos
- GDScript — linguagem de programação
- Pixel art — estilo visual

---

## Engenharia de software

**Design Patterns:** o projeto aplica o padrão **Singleton** nos sistemas globais (`ClueManager`, `Transition`, `Hud`, `Inventory`, `Report`, `Credits`), todos registrados como Autoloads do Godot para garantir instância única e acesso global. O padrão **Observer** é aplicado no sistema de pistas: `ClueManager` emite o sinal `clue_added` e os sistemas `Hud`, `Inventory` e `scene_completion` reagem a ele de forma desacoplada via `connect()`.

**Código Limpo** (Martin, 2011): nomes expressivos, funções com responsabilidade única e remoção de código morto (prints de debug). A duplicação de lógica de highlight entre `interactable.gd` e `interactable_with_credits.gd` foi eliminada com a criação de `interactable_base.gd` como classe base, aplicando o princípio DRY.

**Tracer Bullet:** o desenvolvimento priorizou um fluxo ponta a ponta funcional desde cedo (prólogo → pista coletada → HUD atualizado), validando toda a arquitetura antes de escalar o conteúdo para as demais cenas.

---

## Estrutura do projeto

```
res://
├── Assets/                   # sprites, retratos, imagens
├── Dialogues/                # arquivos .dialogue e balloon.tscn
├── Scenes/                   # cenas do jogo (.tscn)
├── scripts/
│   ├── interactable_base.gd  # classe base: highlight + detecção de clique
│   ├── interactable.gd       # objetos clicáveis com diálogo e pistas
│   ├── interactable_with_credits.gd
│   ├── scene_door.gd         # porta de transição entre cenas
│   ├── auto_dialogue.gd      # cutscene automática ao carregar cena
│   ├── scene_completion.gd   # detecta conclusão de cena
│   ├── clue_manager.gd       # Singleton/Observer — inventário de pistas
│   ├── hud.gd                # Singleton — HUD de pistas por cena
│   ├── inventory.gd          # Singleton — inventário completo (Tab)
│   ├── report.gd             # Singleton — relatório epidemiológico
│   ├── credits.gd            # Singleton — tela de créditos
│   └── transition.gd         # Singleton — fade entre cenas
└── addons/                   # Dialogue Manager 3
```

---

## Como rodar

1. Clone o repositório
2. Abra o projeto no **Godot 4.6**
3. Pressione **F5** para rodar a partir da cena principal

Para exportar para Windows: Project → Export → Manage Export Templates → baixar templates para 4.6.stable → Export Project com **Embed PCK** marcado.

---

## Equipe

| Nome | Função |
|---|---|
| Vitória Assumpção | Dev |
| Jean Maciel | Design |
| Ghiovanna Ventura | Pesquisa |


---

## Licença

Projeto acadêmico desenvolvido para fins educacionais. Todos os personagens são fictícios. A narrativa é baseada em situações reais, mas não representa nenhum profissional ou instituição específica.

> *"Nenhum personagem representa um profissional culpado — todos representam profissionais que fazem seu trabalho dentro das condições que o sistema oferece. Torná-los visíveis é o primeiro passo para construir sistemas mais seguros."*