"""
Rode da pasta principal do projeto:
    python conectar_telas.py

1) Confere o item 2 ({% load static %} e caminhos de css/js/img)
2) Garante as rotas das telas no urls.py (necessário para o {% url %} funcionar)
3) Faz o item 3: troca links "pagina.html" e "#" por {% url 'Camisa12:...' %}
"""
import re
from pathlib import Path

BASE = Path("Django/Camisa12")
TEMPLATES = BASE / "templates"
URLS = BASE / "urls.py"

# Telas que só mostram HTML -> nome da rota
TELAS = {
    "futebol": "futebol.html",
    "nba": "nba.html",
    "nfl": "nfl.html",
    "lojas": "lojas.html",
    "sobre": "sobre.html",
    "lancamento": "lancamento.html",
    "carrinho": "carrinho.html",
}

# ---------------------------------------------------------------- item 2 (correção)
print("=== ITEM 2: aplicando {% static %} ===")
for f in sorted(TEMPLATES.glob("*.html")):
    if f.name.startswith("HTML - "):
        continue
    txt = f.read_text(encoding="utf-8")
    orig = txt
    # href="css/style.css" -> href="{% static 'css/style.css' %}"
    txt = re.sub(r'(href|src)="((?:css|js|img)/[^"{}]+)"',
                 lambda m: m.group(1) + '="{% static \'' + m.group(2) + '\' %}"', txt)
    if "{% static" in txt:
        # garante {% load static %} uma única vez, na primeira linha
        txt = txt.replace("{% load static %}\n", "").replace("{% load static %}", "")
        txt = "{% load static %}\n" + txt
    if txt != orig:
        f.write_text(txt, encoding="utf-8")
        print(f"  ✓ {f.name}")
print()

# ---------------------------------------------------------------- item 2 (conferência)
print("=== ITEM 2: conferindo {% static %} ===")
problemas = 0
for f in sorted(TEMPLATES.glob("*.html")):
    if f.name.startswith("HTML - "):
        continue  # telas antigas, não usadas no site
    txt = re.sub(r"<!--.*?-->", "", f.read_text(encoding="utf-8"), flags=re.S)
    usa_static = "{% static" in txt
    tem_load = "{% load static %}" in txt
    relativos = re.findall(
        r'(?:href|src)="(?!https?:|mailto:|#|\{|/)([^"]+\.(?:css|js|svg|png|jpe?g|gif|webp|ico))"', txt)
    erros = []
    if usa_static and not tem_load:
        erros.append("usa {% static %} mas falta {% load static %} no topo")
    if tem_load and not txt.lstrip().startswith("{% load static %}") and \
            txt.find("{% load static %}") > txt.find("{% static"):
        erros.append("{% load static %} precisa vir ANTES do primeiro {% static %}")
    for r in relativos:
        erros.append(f'caminho ainda relativo: "{r}"')
    if erros:
        problemas += len(erros)
        print(f"  ✗ {f.name}")
        for e in erros:
            print(f"      - {e}")
    else:
        print(f"  ✓ {f.name}")
print("  -> item 2 OK!\n" if problemas == 0 else f"  -> {problemas} ajuste(s) pendente(s) no item 2\n")

# ---------------------------------------------------------------- rotas
print("=== ROTAS no urls.py ===")
urls = URLS.read_text(encoding="utf-8")
novas = []
if '"home"' not in urls and "'home'" not in urls:
    novas.append('    path("", TemplateView.as_view(template_name="futebol.html"), name="home"),')
for nome, tpl in TELAS.items():
    if f'name="{nome}"' not in urls and f"name='{nome}'" not in urls:
        novas.append(f'    path("{nome}/", TemplateView.as_view(template_name="{tpl}"), name="{nome}"),')
if novas:
    if "TemplateView" not in urls.split("urlpatterns")[0]:
        urls = urls.replace("from django.urls import path",
                            "from django.urls import path\nfrom django.views.generic import TemplateView", 1)
    fim = urls.rstrip().rfind("]")
    urls = urls[:fim].rstrip() + "\n\n    # Telas do site\n" + "\n".join(novas) + "\n\n]\n"
    URLS.write_text(urls, encoding="utf-8")
    print(f"  + {len(novas)} rota(s) adicionada(s)\n")
else:
    print("  ✓ todas as rotas já existem\n")

# ---------------------------------------------------------------- item 3
print("=== ITEM 3: convertendo links ===")
def u(nome):
    return "{% url 'Camisa12:" + nome + "' %}"

arquivo_para_rota = {tpl: nome for nome, tpl in TELAS.items()}

# links "#" que já têm destino óbvio, identificados pelo texto/classe
placeholders = [
    (r'<a href="#">Início</a>', f'<a href="{u("home")}">Início</a>'),
    (r'<a href="#">Lojas</a>', f'<a href="{u("lojas")}">Lojas</a>'),
    (r'<a href="#">Lojas Parceiras</a>', f'<a href="{u("lojas")}">Lojas Parceiras</a>'),
    (r'<a href="#">Quem Somos</a>', f'<a href="{u("sobre")}">Quem Somos</a>'),
    (r'<a href="#" class="acoes__entrar">', f'<a href="{u("login")}" class="acoes__entrar">'),
    (r'<a href="#" class="btn">Criar conta', f'<a href="{u("cadastro")}" class="btn">Criar conta'),
    (r'<a href="#" class="link-entrar">', f'<a href="{u("login")}" class="link-entrar">'),
    (r'<a href="#" class="botao">CRIAR CONTA', f'<a href="{u("cadastro")}" class="botao">CRIAR CONTA'),
    (r'<a href="#" class="logo">', f'<a href="{u("home")}" class="logo">'),
]

total = 0
for f in sorted(TEMPLATES.glob("*.html")):
    if f.name.startswith("HTML - "):
        continue
    txt = f.read_text(encoding="utf-8")
    orig = txt
    # href="futebol.html" / href="nba.html#catalogo" etc.
    def troca(m):
        arq, ancora = m.group(1), m.group(2) or ""
        if arq in arquivo_para_rota:
            return f'href="{u(arquivo_para_rota[arq])}{ancora}"'
        return m.group(0)
    txt = re.sub(r'href="([\w\-]+\.html)(#[^"]*)?"', troca, txt)
    for velho, novo in placeholders:
        txt = txt.replace(velho, novo)
    if txt != orig:
        n = txt.count("{% url") - orig.count("{% url")
        total += n
        f.write_text(txt, encoding="utf-8")
        print(f"  ✓ {f.name}: {n} link(s)")
print(f"  -> {total} link(s) convertidos")
print("\nPronto. Rode: cd Django && python manage.py runserver")
