import { ApplicationConfig, provideZoneChangeDetection } from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideAnimations } from '@angular/platform-browser/animations';
import { provideHttpClient, withInterceptors } from '@angular/common/http';

import { routes } from './app.routes';
import { provideToastr } from 'ngx-toastr'; // Assuming ngx-toastr will be used for notifications
import { provideStore } from '@ngrx/store'; // Assuming NgRx will be used for state management
import { provideEffects } from '@ngrx/effects';
import { provideStoreDevtools } from '@ngrx/store-devtools';
import { environment } from '../environments/environment';
import { jwtTokenInterceptor } from './core/interceptors/jwt-token-interceptor';
import { errorHandlerInterceptor } from './core/interceptors/error-handler-interceptor';

export const appConfig: ApplicationConfig = {
  providers: [
    provideZoneChangeDetection({ eventCoalescing: true }),
    provideRouter(routes),
    provideAnimations(),
    provideHttpClient(withInterceptors([jwtTokenInterceptor, errorHandlerInterceptor])),
    provideToastr({
      timeOut: 3000,
      positionClass: 'toast-bottom-right',
      preventDuplicates: true,
    }),
    provideStore(), // Add NgRx store
    provideEffects(), // Add NgRx effects
    !environment.production ? provideStoreDevtools() : [], // Add NgRx DevTools in development
  ]
};
