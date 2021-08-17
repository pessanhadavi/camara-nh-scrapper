require 'open-uri'
class ProjectsController < ApplicationController
  before_action :set_project, only: [:show]

  def index
    @projects = Project.all
  end

  def show
  end

  def scrape
    Project.destroy_all
    num_laws = check_number_of_laws
    i = 1

    # until Project.count == num_laws do  # Uncomment this line to get all projects
    until Project.count == 100 do # As there are many projects, this line is for testing purposes. It checks 2 pages
      url = "https://sapl.camaranh.rs.gov.br/materia/pesquisar-materia?page=#{i}&tipo=1&ementa=&numero=&numeracao__numero_materia=&numero_protocolo=&ano=&o=&tipo_listagem=1&tipo_origem_externa=&numero_origem_externa=&ano_origem_externa=&data_origem_externa_0=&data_origem_externa_1=&local_origem_externa=&data_apresentacao_0=&data_apresentacao_1=&data_publicacao_0=&data_publicacao_1=&autoria__autor=&autoria__primeiro_autor=1&autoria__autor__tipo=&autoria__autor__parlamentar_set__filiacao__partido=&relatoria__parlamentar_id=&em_tramitacao=&tramitacao__unidade_tramitacao_destino=&tramitacao__status=&materiaassunto__assunto=&indexacao="
      html = URI.open(url)
      page = Nokogiri::HTML(html)

      rows = page.xpath('//table/tr')
      rows.each do |row|
        Project.create init_instatiation(row)
      end

      i += 1
    end
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def init_instatiation(row)
    project = {}

    project[:law] = row.css('a')[0].text[/PL\s\w*\/\w*/]
    law_url_path = row.css('a')[0].attribute('href').value
    project[:law_url] = "https://sapl.camaranh.rs.gov.br#{law_url_path}"
    project[:description] = row.css('div.dont-break-out').text
    row.css('strong').each do |topic|
      case
      when topic.text.include?("Apresentação")
        project[:apresentation_date] = topic.next.text.strip
      when topic.text.include?("Autor")
        project[:author] = topic.next.text.strip[1..-1]
      when topic.text.include?("Localização Atual")
        project[:current_local] = topic.next.text.strip[1..-1]
      when topic.text.include?("Status")
        project[:status] = topic.next.text.strip[1..-1]
      when topic.text.include?("Data Fim Prazo")
        project[:deadline] = topic.next.text.strip[1..-1]
      when topic.text.include?("Data da última Tramitação")
        project[:last_processing] = topic.next.text.strip[1..-1]
      when topic.text.include?("Ultima Ação")
        project[:last_action] = topic.next.text.strip[2..-1]
      when topic.text.include?("Documentos Acessórios")
        project[:accessory_docs] = topic.next.next.text.strip
        access_url = topic.next.next.attribute('href').value
        project[:accessory_docs_url] = "https://sapl.camaranh.rs.gov.br#{access_url}"
      when topic.text.include?("Texto Original")
        original_url = topic.css('a').attribute('href').value
        project[:original_text] = "https://sapl.camaranh.rs.gov.br#{original_url}"
      end
    end
    project
  end

  def check_number_of_laws
    url = "https://sapl.camaranh.rs.gov.br/materia/pesquisar-materia?page=1&tipo=1&ementa=&numero=&numeracao__numero_materia=&numero_protocolo=&ano=&o=&tipo_listagem=1&tipo_origem_externa=&numero_origem_externa=&ano_origem_externa=&data_origem_externa_0=&data_origem_externa_1=&local_origem_externa=&data_apresentacao_0=&data_apresentacao_1=&data_publicacao_0=&data_publicacao_1=&autoria__autor=&autoria__primeiro_autor=1&autoria__autor__tipo=&autoria__autor__parlamentar_set__filiacao__partido=&relatoria__parlamentar_id=&em_tramitacao=&tramitacao__unidade_tramitacao_destino=&tramitacao__status=&materiaassunto__assunto=&indexacao="
    html = URI.open(url)
    page = Nokogiri::HTML(html)
    page.css('h3').text[/\d+/].to_i
  end
end
