import { Component } from '@angular/core';
import { bootstrapApplication } from '@angular/platform-browser';

@Component({
  selector: 'app-root',
  standalone: true,
  template: `
    <div class="card">
      <h1>🚀 ${{ values.name }}</h1>
      <p>${{ values.description }}</p>
      <hr style="border-color: #334155; margin: 1.5rem 0;">
      <p>Successfully scaffolded by <strong>Backstage Developer Portal</strong> and deployed to Azure App Service via Terraform!</p>
      <div class="badge">Runtime: Node.js 24 LTS</div>
    </div>
  `
})
export class App {}

bootstrapApplication(App).catch((err) => console.error(err));
