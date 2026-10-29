package views;

import java.util.Scanner;

public class MenuPrincipal {

    public void exibirMenu() {
        Scanner sc = new Scanner(System.in);

        while (true) {
            System.out.println("\n=== MENU PRINCIPAL ===");
            System.out.println("1 - Gerenciar Catequizandos");
            System.out.println("2 - Gerenciar Catequistas");
            System.out.println("3 - Gerenciar Turmas");
            System.out.println("0 - Sair");

            System.out.print("Escolha: ");
            int opcao = sc.nextInt();

            switch (opcao) {
                case 1:
                    System.out.println("Abrindo gestão de catequizandos...");
                    break;
                case 2:
                    System.out.println("Abrindo gestão de catequistas...");
                    break;
                case 3:
                    System.out.println("Abrindo gestão de turmas...");
                    break;
                case 0:
                    System.out.println("Sistema encerrado.");
                    return;
                default:
                    System.out.println("Opção inválida.");
            }
        }
    }
}
