(() => {
  const catalogo = document.querySelector('.produtos');
  const filtros = document.querySelector('.filtros');
  if (!catalogo || !filtros) return;

  const cards = [...catalogo.querySelectorAll('.card')];
  const busca = filtros.querySelector('input[type="search"]');
  const filtroTime = filtros.querySelector('.filtro-time');
  const filtroPreco = filtros.querySelector('select[aria-label="Faixa de preço"]');
  const ordenar = filtros.querySelector('select[aria-label="Ordenar"]');
  const filtroFavoritos = filtros.querySelector('.filtro-favoritos');
  const total = document.querySelector('.catalogo__total');
  const paginacao = document.querySelector('.paginacao');
  const chaveFavoritos = 'camisa12-favoritos-v1';
  const produtosPorPagina = 6;
  let paginaAtual = 1;

  const lerFavoritos = () => {
    try {
      const valor = JSON.parse(localStorage.getItem(chaveFavoritos) || '[]');
      return Array.isArray(valor) ? valor : [];
    } catch {
      return [];
    }
  };

  const salvarFavoritos = (ids) => {
    try {
      localStorage.setItem(chaveFavoritos, JSON.stringify(ids));
    } catch (erro) {
      console.error('Não foi possível salvar os favoritos neste navegador.', erro);
    }
  };

  const normalizar = (texto) => texto
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .trim();

  const precoDo = (card) => {
    const texto = card.querySelector('.card__preco')?.textContent || '';
    return Number(texto.replace(/[^\d,]/g, '').replace(',', '.')) || 0;
  };

  const idDo = (card) => {
    const nome = card.querySelector('.card__nome')?.textContent || '';
    const time = card.querySelector('.card__time')?.textContent || '';
    return normalizar(`${time}-${nome}`);
  };

  // Monta as opções a partir dos times realmente presentes no catálogo.
  if (filtroTime) {
    const times = [...new Set(
      cards.map(card => card.querySelector('.card__time')?.textContent.trim()).filter(Boolean)
    )].sort((a, b) => a.localeCompare(b, 'pt-BR'));

    times.forEach(time => {
      const option = document.createElement('option');
      option.value = time;
      option.textContent = time;
      filtroTime.appendChild(option);
    });
  }

  cards.forEach(card => {
    const midia = card.querySelector('.card__midia');
    if (!midia || midia.querySelector('.favorito-btn')) return;

    const botao = document.createElement('button');
    botao.type = 'button';
    botao.className = 'favorito-btn';
    botao.setAttribute('aria-label', 'Adicionar aos favoritos');
    botao.innerHTML = '♡ <span>Favoritar</span>';
    midia.appendChild(botao);

    botao.addEventListener('click', () => {
      const favoritos = lerFavoritos();
      const id = idDo(card);
      const atualizado = favoritos.includes(id)
        ? favoritos.filter(item => item !== id)
        : [...favoritos, id];

      salvarFavoritos(atualizado);
      atualizarBotoesFavoritos();
      paginaAtual = 1;
      aplicarFiltros();
    });
  });

  function atualizarBotoesFavoritos() {
    const favoritos = lerFavoritos();
    cards.forEach(card => {
      const botao = card.querySelector('.favorito-btn');
      if (!botao) return;

      const ativo = favoritos.includes(idDo(card));
      botao.classList.toggle('favorito-btn--ativo', ativo);
      botao.innerHTML = ativo ? '♥ <span>Favoritado</span>' : '♡ <span>Favoritar</span>';
      botao.setAttribute('aria-pressed', String(ativo));
      botao.setAttribute('aria-label', ativo ? 'Remover dos favoritos' : 'Adicionar aos favoritos');
    });
  }

  function criarBotaoPagina(rotulo, destino, opcoes = {}) {
    const botao = document.createElement('button');
    botao.type = 'button';
    botao.className = 'paginacao__botao';
    botao.textContent = rotulo;
    botao.disabled = Boolean(opcoes.desabilitado);

    if (opcoes.ativo) {
      botao.classList.add('ativa');
      botao.setAttribute('aria-current', 'page');
    }
    if (opcoes.desabilitado) botao.classList.add('desativada');
    if (opcoes.rotuloAcessivel) botao.setAttribute('aria-label', opcoes.rotuloAcessivel);

    botao.addEventListener('click', () => {
    paginaAtual = destino;
    aplicarFiltros();
    catalogo.scrollIntoView({ behavior: 'smooth', block: 'start' });
    });
    return botao;
    }

  function renderizarPaginacao(totalPaginas) {
    if (!paginacao) return;
    paginacao.replaceChildren();
    paginacao.hidden = totalPaginas <= 1;
    if (totalPaginas <= 1) return;

    paginacao.appendChild(criarBotaoPagina('←', Math.max(1, paginaAtual - 1), {
      desabilitado: paginaAtual === 1,
      rotuloAcessivel: 'Página anterior'
    }));

    for (let numero = 1; numero <= totalPaginas; numero += 1) {
      paginacao.appendChild(criarBotaoPagina(String(numero), numero, {
        ativo: numero === paginaAtual,
        rotuloAcessivel: `Página ${numero}`
      }));
    }

    paginacao.appendChild(criarBotaoPagina('→', Math.min(totalPaginas, paginaAtual + 1), {
      desabilitado: paginaAtual === totalPaginas,
      rotuloAcessivel: 'Próxima página'
    }));
  }

  function aplicarFiltros() {
    const termo = normalizar(busca?.value || '');
    const timeSelecionado = filtroTime?.value || '';
    const faixa = filtroPreco?.selectedIndex ?? 0;
    const soFavoritos = filtroFavoritos?.value === 'favoritos';
    const favoritos = lerFavoritos();

    let produtosFiltrados = cards.filter(card => {
      const texto = normalizar(card.textContent);
      const preco = precoDo(card);
      const bateBusca = !termo || texto.includes(termo);
      const bateTime = !timeSelecionado || card.querySelector('.card__time')?.textContent.trim() === timeSelecionado;
      const batePreco = faixa === 0 ||
        (faixa === 1 && preco <= 200) ||
        (faixa === 2 && preco > 200 && preco <= 350) ||
        (faixa === 3 && preco > 350);
      const bateFavoritos = !soFavoritos || favoritos.includes(idDo(card));
      return bateBusca && bateTime && batePreco && bateFavoritos;
    });

    const modoOrdenacao = ordenar?.selectedIndex ?? 0;
    if (modoOrdenacao === 1) produtosFiltrados.sort((a, b) => precoDo(a) - precoDo(b));
    if (modoOrdenacao === 2) produtosFiltrados.sort((a, b) => precoDo(b) - precoDo(a));
    if (modoOrdenacao === 3) {
      const nota = card => Number(card.querySelector('.avaliacao')?.textContent.match(/[\d.]+/)?.[0] || 0);
      produtosFiltrados.sort((a, b) => nota(b) - nota(a));
    }

    const totalPaginas = Math.max(1, Math.ceil(produtosFiltrados.length / produtosPorPagina));
    paginaAtual = Math.min(paginaAtual, totalPaginas);
    const inicio = (paginaAtual - 1) * produtosPorPagina;
    const idsDaPagina = new Set(produtosFiltrados.slice(inicio, inicio + produtosPorPagina));

    cards.forEach(card => {
      card.hidden = !idsDaPagina.has(card);
    });

    if (total) {
      const quantidade = produtosFiltrados.length;
      total.textContent = `${quantidade} produto${quantidade === 1 ? '' : 's'} encontrado${quantidade === 1 ? '' : 's'}`;
    }

    renderizarPaginacao(totalPaginas);
  }

  filtros.addEventListener('submit', event => event.preventDefault());
  [busca, filtroTime, filtroPreco, ordenar, filtroFavoritos]
    .filter(Boolean)
    .forEach(campo => campo.addEventListener(campo === busca ? 'input' : 'change', () => {
      paginaAtual = 1;
      aplicarFiltros();
    }));

  atualizarBotoesFavoritos();
  aplicarFiltros();
})();
