document.addEventListener("DOMContentLoaded", function() {
    const container = document.getElementById('github-container');
    
    // Only run this on the projects page
    if(container) {
        const username = 'bitresearch2006';
        const url = `https://api.github.com/users/${username}/repos`;

        fetch(url)
        .then(response => {
            if (!response.ok) {
                throw new Error("Network response was not ok");
            }
            return response.json();
        })
        .then(data => {
            container.innerHTML = ''; // Clear "Loading..." text
            
            // Sort by recently updated
            data.sort((a, b) => new Date(b.updated_at) - new Date(a.updated_at));

            data.forEach(repo => {
                // Skip forked repos if you want only your own work
                if(repo.fork) return; 

                const card = document.createElement('div');
                card.className = 'card';
                
                card.innerHTML = `
                    <h3>${repo.name}</h3>
                    <p>${repo.description ? repo.description : 'No description provided.'}</p>
                    <div style="margin-top: 15px; font-size: 0.9em; color: #666;">
                        <span style="margin-right: 10px;">⭐ ${repo.stargazers_count}</span>
                        <span>💻 ${repo.language ? repo.language : 'Code'}</span>
                    </div>
                    <a href="${repo.html_url}" target="_blank" style="display:block; margin-top: 15px; color:#3b82f6; text-decoration:none; font-weight:bold;">View Code &rarr;</a>
                `;
                container.appendChild(card);
            });
        })
        .catch(error => {
            container.innerHTML = `<p>Error loading projects. Please visit our <a href="https://github.com/${username}">GitHub Profile</a> directly.</p>`;
            console.error('Error fetching repos:', error);
        });
    }
});