package repository.impl;

import repository.CatequizandoRepository;
import models.Catequizando;

import java.util.ArrayList;
import java.util.List;

public class CatequizandoRepositoryMemoria implements CatequizandoRepository {

    private List<Catequizando> banco = new ArrayList<>();

    @Override
    public void salvar(Catequizando c) {
        banco.add(c);
    }

    @Override
    public void atualizar(Catequizando c) {
        excluir(c.getId());
        banco.add(c);
    }

    @Override
    public void excluir(Long id) {
        banco.removeIf(c -> c.getId().equals(id));
    }

    @Override
    public Catequizando buscarPorId(Long id) {
        return banco.stream()
                .filter(c -> c.getId().equals(id))
                .findFirst()
                .orElse(null);
    }

    @Override
    public List<Catequizando> listarTodos() {
        return banco;
    }
}
