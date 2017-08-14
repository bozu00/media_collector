defmodule Crawler.Process do

  #######################
  ## Client API 
  #######################

  def root_supervisor do
    :root_supervisor
  end

  def operation_manager do
    :operation_manager
  end

  def domains_supervisor do
    String.to_atom("domains_supervisor")
  end

  def domain_supervisor(domain) do
    String.to_atom("#{domain}_supervisor")
  end

  # def jobs_schedule(domain) do
  #   String.to_atom("#{domain}_jobs_schedule")
  # end

  def jobs_supervisor(domain) do
    String.to_atom("#{domain}_jobs_supervisor")
  end

  def job_supervisor(domain,job_name) do
    String.to_atom("#{domain}_#{job_name}_supervisor")
  end

  def download_manager(domain) do
    String.to_atom("#{domain}_download_manager")
  end

  def scrape_manager(domain, job_name) do
    String.to_atom("#{domain}_#{job_name}_scrape_manager")
  end

  def downloader(domain) do
    String.to_atom("#{domain}_downloader")
  end

  def scraper(domain, job_name) do
    String.to_atom("#{domain}_#{job_name}_scraper")
  end
end
