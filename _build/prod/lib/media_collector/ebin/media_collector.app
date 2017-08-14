{application,media_collector,
             [{applications,[kernel,stdlib,elixir,logger,trot,eex,qex,poison,
                             httpoison,floki,html_sanitize_ex]},
              {description,"media_collector"},
              {modules,['Elixir.CLI','Elixir.Console.Router',
                        'Elixir.Crawler.Application',
                        'Elixir.Crawler.DomainSupervisor',
                        'Elixir.Crawler.DomainsSupervisor',
                        'Elixir.Crawler.DownloadManager',
                        'Elixir.Crawler.DownloadSupervisor',
                        'Elixir.Crawler.DownloadWorker',
                        'Elixir.Crawler.DownloadWorkerSupervisor',
                        'Elixir.Crawler.Downloader',
                        'Elixir.Crawler.JobSupervisor',
                        'Elixir.Crawler.JobsSupervisor',
                        'Elixir.Crawler.OperationManager',
                        'Elixir.Crawler.Process',
                        'Elixir.Crawler.RootSupervisor',
                        'Elixir.Crawler.ScrapeManager',
                        'Elixir.Crawler.ScrapeWorker',
                        'Elixir.Crawler.ScrapeWorkerSupervisor',
                        'Elixir.RegistryTest']},
              {registered,[]},
              {vsn,"0.1.0"},
              {extra_applications,[logger,trot,eex]},
              {mod,{'Elixir.Crawler.Application',[]}}]}.